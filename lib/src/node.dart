// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of butterfly;

/// Configures the state of the UI.
///
/// This class is at the core of the framework.
abstract class Node {
  const Node({this.key});

  final Key key;

  RenderNode instantiate(Tree t);
}

/// Function that receives an [event].
typedef void EventListener(Event event);

/// An event emitted by an element.
class Event {
  Event(this.type, this.targetBaristaId, this.data);

  /// Event type, e.g. [EventType.click].
  final EventType type;

  /// ID of the target.
  final String targetBaristaId;

  /// Event data.
  final Map<String, dynamic> data;

  /// Returns a value from [data].
  dynamic operator[](String key) => data[key];
}

/// A node in the retained tree instantiated from [Node]s.
abstract class RenderNode<N extends Node> {
  RenderNode(this._tree);

  /// The parent node of this node.
  RenderParent get parent => _parent;
  RenderParent _parent;

  /// Looks for the event target within the sub-tree rooted at this render node
  /// and dispatches the [event] to it.
  void dispatchEvent(Event event);

  /// The node tree that this node participates in.
  Tree get tree => _tree;
  final Tree _tree;

  void visitChildren(void visitor(RenderNode child));
  bool canUpdateUsing(Node node);

  /// Remove this node from the tree.
  ///
  /// This operation can be used to temporarily remove nodes in order to move
  /// them around.
  void detach() {
    _parent == null;
    if (_configuration.key is GlobalKey) {
      final GlobalKey key = _configuration.key;
      key.unregister(this);
    }
  }

  /// Attached this node to a [newParent].
  void attach(RenderParent newParent) {
    assert(newParent != null);
    _parent = newParent;
    if (_configuration.key is GlobalKey) {
      final GlobalKey key = _configuration.key;
      key.register(this);
    }
  }

  /// The [Node] that instantiated this retained node.
  N get configuration => _configuration;
  N _configuration;

  /// Updates this node and its children.
  ///
  /// Implementations of this class must override this method and ensure that
  /// all necessary updates to `this` node and its children (if any) happen
  /// correctly. The overridden method must call `super.update` to finalize the
  /// update.
  void update(N newConfiguration, ElementUpdate update) {
    assert(newConfiguration != null);
    _configuration = newConfiguration;
    if (_configuration.key is GlobalKey) {
      final GlobalKey key = _configuration.key;
      key.register(this);
    }
  }
}

abstract class MultiChildNode extends Node {
  const MultiChildNode({Key key, this.children})
    : super(key: key);

  final List<Node> children;
}

/// Whether [node] can be updated from [configuration].
///
/// This is used to decide whether a node should be moved, replaced, removed or
/// updated using the new data (configuration).
// TODO: can this be made inlineable?
bool _canUpdate(RenderNode node, Node configuration) {
  if (!identical(node.configuration.runtimeType, configuration.runtimeType)) {
    return false;
  }

  return node.configuration.key == configuration.key;
}

/// A node that has children.
abstract class RenderParent<N extends Node> extends RenderNode<N> {
  RenderParent(Tree tree) : super(tree);

  /// Whether any of this node's descentant nodes need to be updated.
  bool _hasDescendantsNeedingUpdate = true;
  bool get hasDescendantsNeedingUpdate => _hasDescendantsNeedingUpdate;

  // TODO(yjbanov): rename to setState
  void scheduleUpdate() {
    _hasDescendantsNeedingUpdate = true;
    RenderParent parent = _parent;
    while(parent != null) {
      parent._hasDescendantsNeedingUpdate = true;
      parent = parent.parent;
    }
  }

  /// Updates this node and its children.
  ///
  /// Implementations of this class must override this method and ensure that
  /// all necessary updates to `this` node and its children (if any) happen
  /// correctly. The overridden method must call `super.update` to finalize the
  /// update.
  @override
  void update(N newConfiguration, ElementUpdate update) {
    _hasDescendantsNeedingUpdate = false;
    super.update(newConfiguration, update);
  }
}

/// A node that has multiple children.
abstract class RenderMultiChildParent<N extends MultiChildNode> extends RenderParent<N> {
  RenderMultiChildParent(Tree tree) : super(tree);

  List<RenderNode> _currentChildren;

  @override
  void visitChildren(void visitor(RenderNode child)) {
    if (_currentChildren == null) return;

    for (RenderNode child in _currentChildren) {
      visitor(child);
    }
  }

  @override
  void update(N newConfiguration, ElementUpdate update) {
    // TODO(yjbanov): implement for realz
    if (_currentChildren == null) {
      _currentChildren = <RenderNode>[];
    }

    if (_configuration == newConfiguration) {
      // No need to diff child lists.
      if (hasDescendantsNeedingUpdate) {
        for (int i = 0; i < _currentChildren.length; i++) {
          _currentChildren[i].update(
            newConfiguration.children[i],
            update.updateChildElement(i),
          );
        }
      }

      super.update(newConfiguration, update);
      return;
    }

    final List<Node> newChildren = newConfiguration.children;

    // Simple case: used to have no children; children added
    if (_currentChildren.isEmpty && newChildren != null) {
      for (final newChild in newChildren) {
        RenderNode child = newChild.instantiate(tree);
        final childUpdate = update.insertChildElement(0);
        child.update(newChild, childUpdate);
        child.attach(this);
        _currentChildren.add(child);
      }

      super.update(newConfiguration, update);
      return;
    }

    // Simple case: remove all children if any
    if (newChildren == null || newChildren.isEmpty) {
      if (_currentChildren != null || _currentChildren.isNotEmpty) {
        for (int i = 0; i < _currentChildren.length; i++) {
          _currentChildren[i].detach();
          update.removeChild(i);
        }
        _currentChildren = null;
      }

      super.update(newConfiguration, update);
      return;
    }

    final List<_TrackedChild> currentChildren = <_TrackedChild>[];
    final Map<Key, int> keyMap = <Key, int>{};

    for (int baseIndex = 0; baseIndex < _currentChildren.length; baseIndex++) {
      final RenderNode node = _currentChildren[baseIndex];
      currentChildren.add(new _TrackedChild(baseIndex));
      final Node config = node._configuration;
      final Key key = config.key;
      if (key != null) {
        keyMap[key] = baseIndex;
      }
    }

    List<int> sequence = <int>[];
    List<_Target> targetList = <_Target>[];
    int afterLastUsedUnkeyedChild = 0;
    for (int i = 0; i < newChildren.length; i++) {
      final Node node = newChildren[i];
      final Key key = node.key;
      int baseChild = currentChildren.length;
      if (key != null) {
        int previousIndex = keyMap[key];
        if (previousIndex != null) {
          baseChild = previousIndex;
          _TrackedChild trackedChild = currentChildren[previousIndex];
          RenderNode currentChild = _currentChildren[trackedChild.positionInCurrentChildren];
          if (currentChild.canUpdateUsing(node)) {
            final childUpdate = update.updateChildElement(trackedChild.positionInCurrentChildren);
            currentChild.update(node, childUpdate);
          }
        }
      } else {
        // Start with afterLastUsedUnkeyedChild and scan until the first child
        // we can update. Use it. This approach is naive. It does not support
        // swaps, for example. It does support removes though. For swaps, the
        // developer is expected to use keys anyway.
        int scanner = afterLastUsedUnkeyedChild;
        while(scanner < currentChildren.length) {
          RenderNode currentChild = _currentChildren[scanner];
          if (currentChild.canUpdateUsing(node)) {
            final childUpdate = update.updateChildElement(scanner);
            currentChild.update(node, childUpdate);
            baseChild = scanner;
            afterLastUsedUnkeyedChild = scanner + 1;
            break;
          }
          scanner++;
        }
      }

      if (baseChild != currentChildren.length) {
        currentChildren[baseChild].shouldRetain = true;
        sequence.add(baseChild);
        targetList.add(new _Target(node, baseChild));
      } else {
        targetList.add(new _Target(node, -1));
      }
    }

    // Compute removes
    for (int i = 0; i < currentChildren.length; i++) {
      final currentChild = currentChildren[i];
      if (!currentChild.shouldRetain) {
        _currentChildren[currentChild.positionInCurrentChildren].detach();
        update.removeChild(i);
      }
    }

    // Compute inserts and updates
    List<int> lis = computeLongestIncreasingSubsequence(sequence);
    int insertionPoint = 0;
    List<RenderNode> newChildVector = <RenderNode>[];
    int baseCount = _currentChildren.length;
    for (int i = 0; i < targetList.length; i++) {
      _Target targetEntry = targetList[i];

      // Three possibilities:
      //   - it's a new child => its base index == -1
      //   - it's a moved child => its base index != -1 && base index != insertion index
      //   - it's a stationary child => its base index != -1 && base index == insertion index

      // Index in the base list of the moved child, or -1
      int baseIndex = targetEntry.baseIndex;
      // Index in the base list before which target child must be inserted.
      int insertionIndex = baseCount;
      if (insertionPoint != lis.length) {
        insertionIndex = lis[insertionPoint];
        if (baseIndex == insertionIndex) {
          // We've moved past the element in the target list that
          // corresponds to the insertion point. Advance to the next one.
          insertionPoint++;
        }
      }

      if (baseIndex == -1) {
        // New child
        Node childNode = targetEntry.node;

        // Lock the diff object so child nodes do not push diffs.
        final childInsertion = update.insertChildElement(insertionIndex);
        final childRenderNode = childNode.instantiate(_tree);
        newChildVector.add(childRenderNode);
        childRenderNode.update(childNode, childInsertion);
        childRenderNode.attach(this);
      } else {
        if (baseIndex != insertionIndex) {
          // Moved child
          update.moveChild(insertionIndex, baseIndex);
          newChildVector.add(_currentChildren[baseIndex]);
        } else {
          newChildVector.add(_currentChildren[baseIndex]);
        }
      }
    }
    _currentChildren = newChildVector;

    super.update(newConfiguration, update);
  }

  @override
  void dispatchEvent(Event event) {
    if (_currentChildren == null) return;

    for (final child in _currentChildren) {
      child.dispatchEvent(event);
    }
  }
}

class _TrackedChild {
  _TrackedChild(this.positionInCurrentChildren);

  final int positionInCurrentChildren;
  bool shouldRetain = false;
}

class _Target {
  _Target(this.node, this.baseIndex);

  final Node node;
  final int baseIndex;  // or -1
}

/// Computes the [longest increasing subsequence](http://en.wikipedia.org/wiki/Longest_increasing_subsequence).
///
/// Returns list of indices (rather than values) into [list].
///
/// Complexity: n*log(n)
// TODO: heuristic idea, len(LIS) == 1 iff list is reversed, which in the
// diff could be expressed extremely compactly
List<int> computeLongestIncreasingSubsequence(List<int> list) {
  final len = list.length;
  final predecessors = <int>[];
  final mins = <int>[0];
  int longest = 0;
  for (int i = 0; i < len; i++) {
    // Binary search for the largest positive `j ≤ longest`
    // such that `list[mins[j]] < list[i]`
    int elem = list[i];
    int lo = 1;
    int hi = longest;
    while (lo <= hi) {
      int mid = (lo + hi) ~/ 2;
      if (list[mins[mid]] < elem) {
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }

    // After searching, `lo` is 1 greater than the
    // length of the longest prefix of `list[i]`
    int expansionIndex = lo;

    // The predecessor of `list[i]` is the last index of
    // the subsequence of length `newLongest - 1`
    predecessors.add(mins[expansionIndex - 1]);
    if (expansionIndex >= mins.length) {
      mins.add(i);
    } else {
      mins[expansionIndex] = i;
    }

    if (expansionIndex > longest) {
      // If we found a subsequence longer than any we've
      // found yet, update `longest`
      longest = expansionIndex;
    }
  }

  // Reconstruct the longest subsequence
  final seq = new List<int>(longest);
  int k = mins[longest];
  for (int i = longest - 1; i >= 0; i--) {
    seq[i] = list[k];
    k = predecessors[k];
  }
  return seq;
}
