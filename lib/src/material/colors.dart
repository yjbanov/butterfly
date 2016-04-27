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

/// Material color definitions.

const matBlack = '#000';
const matWhite = '#fff';

// Opacities to be used on a light background
const matOpacityStrong = 0.87; // Standard opacity unless otherwise listed.
const matOpacityLight = 0.54;
const matOpacityLighter = 0.38;

// Opacities to be used on a dark background
const matDarkOpacityStrong = 1.0;
const matDarkOpacityLight = 0.7;
const matDarkOpacityLighter = 0.5;

/// Semi-transparent black/white text as used in most material specs.
const matTransparentBlack = 'rgba(0, 0, 0, ${matOpacityStrong})';
const matTransparentWhite = 'rgba(255, 255, 255, ${matDarkOpacityStrong})';
const matLightTransparentBlack = 'rgba(0, 0, 0, ${matOpacityLight})';
const matLightTransparentWhite = 'rgba(255, 255, 255, ${matDarkOpacityLight})';
const matLighterTransparentBlack = 'rgba(0, 0, 0, ${matOpacityLighter})';
const matLighterTransparentWhite = 'rgba(255, 255, 255, ${matDarkOpacityLighter})';

/// Red
const matRed50 = '#fbe9e7';
const matRed100 = '#f4c7c3';
const matRed200 = '#eda29b';
const matRed300 = '#e67c73';
const matRed400 = '#e06055';
const matRed500 = '#db4437';
const matRed600 = '#d23f31';
const matRed700 = '#c53929';
const matRed800 = '#b93221';
const matRed900 = '#a52714';

const matRedA100 = '#ff8a80';
const matRedA200 = '#ff5252';
const matRedA400 = '#ff1744';
const matRedA700 = '#d50000';
const matRed = '${matRed500}';

/// Pinks
const matPink50 = '#fce4ec';
const matPink100 = '#f8bbd0';
const matPink200 = '#f48fb1';
const matPink300 = '#f06292';
const matPink400 = '#ec407a';
const matPink500 = '#e91e63';
const matPink600 = '#d81b60';
const matPink700 = '#c2185b';
const matPink800 = '#ad1457';
const matPink900 = '#880e4f';

const matPinkA100 = '#ff80ab';
const matPinkA200 = '#ff4081';
const matPinkA400 = '#f50057';
const matPinkA700 = '#c51162';
const matPink = '${matPink500}';

/// Purples
const matPurple50 = '#f3e5f5';
const matPurple100 = '#e1bee7';
const matPurple200 = '#ce93d8';
const matPurple300 = '#ba68c8';
const matPurple400 = '#ab47bc';
const matPurple500 = '#9c27b0';
const matPurple600 = '#8e24aa';
const matPurple700 = '#7b1fa2';
const matPurple800 = '#6a1b9a';
const matPurple900 = '#4a148c';

const matPurpleA100 = '#ea80fc';
const matPurpleA200 = '#e040fb';
const matPurpleA400 = '#d500f9';
const matPurpleA700 = '#aa00ff';
const matPurple = '${matPurple500}';


/// Deep Purples
const matDeepPurple50 = '#ede7f6';
const matDeepPurple100 = '#d1c4e9';
const matDeepPurple200 = '#b39ddb';
const matDeepPurple300 = '#9575cd';
const matDeepPurple400 = '#7e57c2';
const matDeepPurple500 = '#673ab7';
const matDeepPurple600 = '#5e35b1';
const matDeepPurple700 = '#512da8';
const matDeepPurple800 = '#4527a0';
const matDeepPurple900 = '#311b92';

const matDeepPurpleA100 = '#b388ff';
const matDeepPurpleA200 = '#7c4dff';
const matDeepPurpleA400 = '#651fff';
const matDeepPurpleA700 = '#6200ea';
const matDeepPurple = '${matDeepPurple500}';


/// Indigo
const matIndigo50 = '#e8eaf6';
const matIndigo100 = '#c5cae9';
const matIndigo200 = '#9fa8da';
const matIndigo300 = '#7986cb';
const matIndigo400 = '#5c6bc0';
const matIndigo500 = '#3f51b5';
const matIndigo600 = '#3949ab';
const matIndigo700 = '#303f9f';
const matIndigo800 = '#283593';
const matIndigo900 = '#1a237e';

const matIndigoA100 = '#8c9eff';
const matIndigoA200 = '#536dfe';
const matIndigoA400 = '#3d5afe';
const matIndigoA700 = '#304ffe';
const matIndigo = '${matIndigo500}';


/// Google Blue
const matBlue50 = '#e8f0fe';
const matBlue100 = '#c6dafc';
const matBlue200 = '#a1c2fa';
const matBlue300 = '#7baaf7';
const matBlue400 = '#5e97f6';
const matBlue500 = '#4285f4';
const matBlue600 = '#3b78e7';
const matBlue700 = '#3367d6';
const matBlue800 = '#2a56c6';
const matBlue900 = '#1c3aa9';

const matBlueA100 = '#82b1ff';
const matBlueA200 = '#448aff';
const matBlueA400 = '#2979ff';
const matBlueA700 = '#2962ff';
const matBlue = '${matBlue500}';


/// Light Blues
const matLightBlue50 = '#e1f5fe';
const matLightBlue100 = '#b3e5fc';
const matLightBlue200 = '#81d4fa';
const matLightBlue300 = '#4fc3f7';
const matLightBlue400 = '#29b6f6';
const matLightBlue500 = '#03a9f4';
const matLightBlue600 = '#039be5';
const matLightBlue700 = '#0288d1';
const matLightBlue800 = '#0277bd';
const matLightBlue900 = '#01579b';

const matLightBlueA100 = '#80d8ff';
const matLightBlueA200 = '#40c4ff';
const matLightBlueA400 = '#00b0ff';
const matLightBlueA700 = '#0091ea';
const matLightBlue = '${matLightBlue500}';


/// Cyan
const matCyan50 = '#e0f7fa';
const matCyan100 = '#b2ebf2';
const matCyan200 = '#80deea';
const matCyan300 = '#4dd0e1';
const matCyan400 = '#26c6da';
const matCyan500 = '#00bcd4';
const matCyan600 = '#00acc1';
const matCyan700 = '#0097a7';
const matCyan800 = '#00838f';
const matCyan900 = '#006064';

const matCyanA100 = '#84ffff';
const matCyanA200 = '#18ffff';
const matCyanA400 = '#00e5ff';
const matCyanA700 = '#00b8d4';
const matCyan = '${matCyan500}';


/// Teals
const matTeal50 = '#e0f2f1';
const matTeal100 = '#b2dfdb';
const matTeal200 = '#80cbc4';
const matTeal300 = '#4db6ac';
const matTeal400 = '#26a69a';
const matTeal500 = '#009688';
const matTeal600 = '#00897b';
const matTeal700 = '#00796b';
const matTeal800 = '#00695c';
const matTeal900 = '#004d40';

const matTealA100 = '#a7ffeb';
const matTealA200 = '#64ffda';
const matTealA400 = '#1de9b6';
const matTealA700 = '#00bfa5';
const matTeal = '${matTeal500}';


/// Google Green
const matGreen50 = '#e2f3eb';
const matGreen100 = '#b7e1cd';
const matGreen200 = '#87ceac';
const matGreen300 = '#57bb8a';
const matGreen400 = '#33ac71';
const matGreen500 = '#0f9d58';
const matGreen600 = '#0d904f';
const matGreen700 = '#0b8043';
const matGreen800 = '#097138';
const matGreen900 = '#055524';

const matGreenA100 = '#b9f6ca';
const matGreenA200 = '#69f0ae';
const matGreenA400 = '#00e676';
const matGreenA700 = '#00c853';
const matGreen = '${matGreen500}';



/// Light Greens
const matLightGreen50 = '#f1f8e9';
const matLightGreen100 = '#dcedc8';
const matLightGreen200 = '#c5e1a5';
const matLightGreen300 = '#aed581';
const matLightGreen400 = '#9ccc65';
const matLightGreen500 = '#8bc34a';
const matLightGreen600 = '#7cb342';
const matLightGreen700 = '#689f38';
const matLightGreen800 = '#558b2f';
const matLightGreen900 = '#33691e';

const matLightGreenA100 = '#ccff90';
const matLightGreenA200 = '#b2ff59';
const matLightGreenA400 = '#76ff03';
const matLightGreenA700 = '#64dd17';
const matLightGreen = '${matLightGreen500}';

/// Limes
const matLime50 = '#f9fbe7';
const matLime100 = '#f0f4c3';
const matLime200 = '#e6ee9c';
const matLime300 = '#dce775';
const matLime400 = '#d4e157';
const matLime500 = '#cddc39';
const matLime600 = '#c0ca33';
const matLime700 = '#afb42b';
const matLime800 = '#9e9d24';
const matLime900 = '#827717';

const matLimeA100 = '#f4ff81';
const matLimeA200 = '#eeff41';
const matLimeA400 = '#c6ff00';
const matLimeA700 = '#aeea00';
const matLime = '${matLime500}';

/// Yellows
const matYellow50 = '#fffde7';
const matYellow100 = '#fff9c4';
const matYellow200 = '#fff59d';
const matYellow300 = '#fff176';
const matYellow400 = '#ffee58';
const matYellow500 = '#ffeb3b';
const matYellow600 = '#fdd835';
const matYellow700 = '#fbc02d';
const matYellow800 = '#f9a825';
const matYellow900 = '#f57f17';

const matYellowA100 = '#ffff8d';
const matYellowA200 = '#ffff00';
const matYellowA400 = '#ffea00';
const matYellowA700 = '#ffd600';
const matYellow = '${matYellow500}';

/// Google Yellow
const matGoogleYellow50 = '#fef6e0';
const matGoogleYellow100 = '#fce8b2';
const matGoogleYellow200 = '#fada80';
const matGoogleYellow300 = '#f7cb4d';
const matGoogleYellow400 = '#f6bf26';
const matGoogleYellow500 = '#f4b400';
const matGoogleYellow600 = '#f2a600';
const matGoogleYellow700 = '#f09300';
const matGoogleYellow800 = '#ee8100';
const matGoogleYellow900 = '#ea6100';

const matGoogleYellowA100 = '#ffde80';
const matGoogleYellowA200 = '#ffcd40';
const matGoogleYellowA400 = '#ffbc00';
const matGoogleYellowA700 = '#ff9e00';
const matGoogleYellow = '${matGoogleYellow500}';

/// Oranges
const matOrange50 = '#fff3e0';
const matOrange100 = '#ffe0b2';
const matOrange200 = '#ffcc80';
const matOrange300 = '#ffb74d';
const matOrange400 = '#ffa726';
const matOrange500 = '#ff9800';
const matOrange600 = '#fb8c00';
const matOrange700 = '#f57c00';
const matOrange800 = '#ef6c00';
const matOrange900 = '#e65100';

const matOrangeA100 = '#ffd180';
const matOrangeA200 = '#ffab40';
const matOrangeA400 = '#ff9100';
const matOrangeA700 = '#ff6d00';
const matOrange = '${matOrange500}';

/// Deep Oranges
const matDeepOrange50 = '#fbe9e7';
const matDeepOrange100 = '#ffccbc';
const matDeepOrange200 = '#ffab91';
const matDeepOrange300 = '#ff8a65';
const matDeepOrange400 = '#ff7043';
const matDeepOrange500 = '#ff5722';
const matDeepOrange600 = '#f4511e';
const matDeepOrange700 = '#e64a19';
const matDeepOrange800 = '#d84315';
const matDeepOrange900 = '#bf360c';

const matDeepOrangeA100 = '#ff9e80';
const matDeepOrangeA200 = '#ff6e40';
const matDeepOrangeA400 = '#ff3d00';
const matDeepOrangeA700 = '#dd2c00';
const matDeepOrange = '${matDeepOrange500}';

/// Browns
const matBrown50 = '#efebe9';
const matBrown100 = '#d7ccc8';
const matBrown200 = '#bcaaa4';
const matBrown300 = '#a1887f';
const matBrown400 = '#8d6e63';
const matBrown500 = '#795548';
const matBrown600 = '#6d4c41';
const matBrown700 = '#5d4037';
const matBrown800 = '#4e342e';
const matBrown900 = '#3e2723';
const matBrown = '${matBrown500}';

/// Greys
const matGrey50 = '#fafafa';
const matGrey100 = '#f5f5f5';
const matGrey200 = '#eeeeee';
const matGrey300 = '#e0e0e0';
const matGrey400 = '#bdbdbd';
const matGrey500 = '#9e9e9e';
const matGrey600 = '#757575';
const matGrey700 = '#616161';
const matGrey800 = '#424242';
const matGrey900 = '#212121';
const matGrey = '${matGrey500}';

const matGray50 = '${matGrey50}';
const matGray100 = '${matGrey100}';
const matGray200 = '${matGrey200}';
const matGray300 = '${matGrey300}';
const matGray400 = '${matGrey400}';
const matGray500 = '${matGrey500}';
const matGray600 = '${matGrey600}';
const matGray700 = '${matGrey700}';
const matGray800 = '${matGrey800}';
const matGray900 = '${matGrey900}';
const matGray = '${matGray500}';


/// Blue Greys
const matBlueGrey50 = '#eceff1';
const matBlueGrey100 = '#cfd8dc';
const matBlueGrey200 = '#b0bec5';
const matBlueGrey300 = '#90a4ae';
const matBlueGrey400 = '#78909c';
const matBlueGrey500 = '#607d8b';
const matBlueGrey600 = '#546e7a';
const matBlueGrey700 = '#455a64';
const matBlueGrey800 = '#37474f';
const matBlueGrey900 = '#263238';
const matBlueGrey = '${matBlueGrey500}';


/// Vanilla colors listed in external facing spec

/// Reds
const matVanillaRed50 = '#fde0dc';
const matVanillaRed100 = '#f9bdbb';
const matVanillaRed200 = '#f69988';
const matVanillaRed300 = '#f36c60';
const matVanillaRed400 = '#e84e40';
const matVanillaRed500 = '#e51c23';
const matVanillaRed600 = '#dd191d';
const matVanillaRed700 = '#d01716';
const matVanillaRed800 = '#c41411';
const matVanillaRed900 = '#b0120a';

const matVanillaRedA100 = '#ff7997';
const matVanillaRedA200 = '#ff5177';
const matVanillaRedA400 = '#ff2d6f';
const matVanillaRedA700 = '#e00032';
const matVanillaRed = '${matVanillaRed500}';

/// Greens
const matVanillaGreen50 = '#d0f8ce';
const matVanillaGreen100 = '#a3e9a4';
const matVanillaGreen200 = '#72d572';
const matVanillaGreen300 = '#42bd41';
const matVanillaGreen400 = '#2baf2b';
const matVanillaGreen500 = '#259b24';
const matVanillaGreen600 = '#0a8f08';
const matVanillaGreen700 = '#0a7e07';
const matVanillaGreen800 = '#056f00';
const matVanillaGreen900 = '#0d5302';

const matVanillaGreenA100 = '#a2f78d';
const matVanillaGreenA200 = '#5af158';
const matVanillaGreenA400 = '#14e715';
const matVanillaGreenA700 = '#12c700';
const matVanillaGreen = '${matVanillaGreen500}';

/// Blues
const matVanillaBlue50 = '#e7e9fd';
const matVanillaBlue100 = '#d0d9ff';
const matVanillaBlue200 = '#afbfff';
const matVanillaBlue300 = '#91a7ff';
const matVanillaBlue400 = '#738ffe';
const matVanillaBlue500 = '#5677fc';
const matVanillaBlue600 = '#4e6cef';
const matVanillaBlue700 = '#455ede';
const matVanillaBlue800 = '#3b50ce';
const matVanillaBlue900 = '#2a36b1';

const matVanillaBlueA100 = '#a6baff';
const matVanillaBlueA200 = '#6889ff';
const matVanillaBlueA400 = '#4d73ff';
const matVanillaBlueA700 = '#4d69ff';
const matVanillaBlue = '${matVanillaBlue500}';

/// Ambers
const matAmber50 = '#fff8e1';
const matAmber100 = '#ffecb3';
const matAmber200 = '#ffe082';
const matAmber300 = '#ffd54f';
const matAmber400 = '#ffca28';
const matAmber500 = '#ffc107';
const matAmber600 = '#ffb300';
const matAmber700 = '#ffa000';
const matAmber800 = '#ff8f00';
const matAmber900 = '#ff6f00';

const matAmberA100 = '#ffe57f';
const matAmberA200 = '#ffd740';
const matAmberA400 = '#ffc400';
const matAmberA700 = '#ffab00';
const matAmber = '${matAmber500}';
