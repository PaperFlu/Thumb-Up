# Thumb Up!

摩擦你的大拇指！

> 阅读本文需要一定的编程经验和探索耐心！ 😉
> 
> 都是因为本人缺乏把它做成一个小白式程序的一点点勤奋。 😛逃）

 “拇指手势” 指的是使用您的拇指**指心**对设备屏幕进行手势操作。如果您使用拇指指侧、拇指指尖、食指指尖之类是不会被识别为拇指操作的！程序根据您每次滑动屏幕时的最大接触面积来识别 “拇指” ，在日常使用情况下，是不会发生误操作的。（小声 BB：如果有水溅到屏幕上，误操作概率就很大了... 😅）

**P S** 作者很懒，本文可能已与最新版本的特性严重脱钩。看着办吧。。

### 本文目录

- [需求](#需求)
- [初次见面](#初次见面)
- [自定义吧！](#自定义吧)
  - [更改手势方向判断方法](#更改手势方向判断方法)
  - [定义新动作函数](#定义新动作函数)
- [体验开始](#体验开始)
- [原生 API](#原生-api)
  - [触摸回调函数](#触摸回调函数)
  - [触摸参数](#触摸参数)
  - [动作函数](#动作函数)
- [问题排查](#问题排查)
- [License](#license)

## 需求

对设备：

1. 支持按压面积检测（？）
2. 拥有 Root 权限
3. 安装了 shell 类软件（如，Termux）
4. Busybox（如，osm0sis 的 Busybox Magisk 模块）

对您：

1. 一定的命令行使用经验

**？问** 我该怎么知道我的设备支不支持按压面积检测呢？

**A 答** 😃 您可以打开开发者选项，点开 “显示指针位置” ，注意屏幕右上角的 Size 一栏，多次点击屏幕，如果设备支持面积检测，Size 一值是**会变化**的。

## 初次见面

拇指手势在第一次使用时需要根据您的设备信息和您的拇指大小进行配置。它需要您的多次按击以获得触摸设备驱动参数、您一般滑动屏幕和用拇指指心滑动屏幕时的接触面积差别，以为日后判断拇指手势作铺垫。

```shell
$ su
# cd /path/to/thumb/touch
# bash adjuster.sh
```

根据 Shell 内的指引一步步操作即可。您可以多次运行该脚本，以获取准确的结果。然后，根据结果更改 `settings.sh` 里的相关变量。

## 自定义吧！

默认情况下，在屏幕右侧，拇指指心滑动时，右上角滑动则返回，左下角滑动则最近任务，右下角滑动则回到桌面；在屏幕右侧，左上角滑动则返回，右下角滑动则最近任务，左下角滑动则回到桌面 —— 这是有原因的！

我们知道，用指心滑动时不方便做出上下左右这样的手势，右手拇指最方便的是右上、左下然后到右下，左上最不方便，左手拇指以竖直方向为轴反之。所以默认以右手拇指左上、左手拇指右上，和回到原点（根据 [`IS_MOVED`](#is_moved) 判断）为取消手势。在程序内部，**同时存在两种**判断方式，一种是以 “向屏幕中心（center）” ，“向屏幕两侧（side）” ，“向上（up）” ，“向下（down）” 为区分的 [`DIRECTIONS_NORMAL`](#directions_normal)；另一种是以类似前一种四种方向的复合（如：centerup）为区分的 [`DIRECTIONS_THUMB`](#directions_thumb)。默认使用后一种。

### 更改手势方向判断方法

上述[动作函数](#动作函数)和方向判断方法都可以在 `settings.sh` 文件中的 [`on_touch_end`](#on_touch_end) 函数内进行更改。

### 定义新动作函数

要定义**新**动作函数，您可以**二选一**：

1. 首选，新建一个 .sh 文件，在其中定义您所想创造的动作函数，然后用类似载入 `stuff.sh` 的方法，在 `settings.sh` 文件的前端载入您的自建文件。
2. 直接对自带动作函数所在文件 `stuff.sh` 进行编辑。

这样，您的新动作函数就可以在 `settings.sh` 内部的[触摸回调函数](#触摸回调函数)里被引用了。

**P S** 自带的 “返回” 、“最近任务” 、“回到桌面” 以及音频类动作函数运行得很慢。这是因为这些 KeyEvent 都是 Java 层的，想要 inject 一个 KeyEvent，必须运行 Java 函数。安卓原生 `input` 命令内部便是通过打开一个新 Java 进程来做到的，浪费了很多时间。可能的解决办法是常驻一个 Java 进程作为子进程然后与其交互（尚未摸透），或者用 Java 重写本程序。

## 体验开始

```
$ su
# cd /path/to/thumb/touch
# bash service.sh
```

运行这行命令后，拇指手势就开始运行了！

Ctrl+C 键可终止手势服务。

## 原生 API

注意对 “当次触摸” 、“同次触摸” 的理解。本文，以 “从开始触摸到触摸结束” 完成一次触摸。

### 触摸回调函数

状态改变时会运行的函数。

##### `on_service_start`

拇指手势开始运行时执行。

##### `on_thumb_change`

在 [`IS_THUMB`](#is_thumb) 的值变化时执行。详见 [`IS_THUMB`](#is_thumb) 。

##### `on_moved_change`

在 [`IS_MOVED`](#is_moved) 的值变化时执行。详见 [`IS_MOVED`](#is_moved) 。

##### `on_gesture_change_normal`

在 [`DIRECTIONS_NORMAL`](#directions_normal) 的值变化时执行。详见 [`DIRECTIONS_NORMAL`](#directions_normal) 。

##### `on_gesture_change_thumb`

在 [`DIRECTIONS_THUMB`](#directions_thumb) 的值变化时执行。详见 [`DIRECTIONS_THUMB`](#directions_normal) 。

##### `on_touch_start`

在屏幕刚检测到触摸时执行。

##### `on_touch_change`

在屏幕被触摸时，[触摸参数](#触摸参数)状态每次刷新后执行。触摸刚开始和刚结束时不会执行。
> **！注** 在当前版本中，该函数被调用时[触摸参数](#触摸参数)**不一定**发生了改变。目前，可以认为，此函数是在开始触摸和触摸结束期间定时运行的函数。

##### `on_touch_end`

在屏幕检测到触摸刚刚结束时执行。

### 触摸参数

[触摸回调函数](#触摸回调函数)可读取、可依赖的（不会在未注明的情况下因程序版本迭代失效的）关于当前触摸信息的变量。

##### `MIN_THUMB_AREA`

Number，判断 [`IS_THUMB`](#is_thumb) 所用到的最小拇指触摸面积值。

##### `MIN_MOVED_DISTANCE`

Number，判断 [`IS_MOVED`](#is_moved) 所用到的最小刻意滑动距离阀值。

##### `AREA_MAX`

Number，当次触摸内的最大屏幕接触面积。

##### `DISTANCE`

Number，当次触摸从开始触摸位置到当前触摸位置的距离。

##### `IS_THUMB`

Boolean，程序是否判定当次触摸系拇指触摸，判断标准 [`MIN_THUMB_AREA`](#min_thumb_area) 。这个值在判定为 `true` 前会在每次触摸面积变化时更新，而在判定为 `true` 后在同次触摸中不再改变。

##### `IS_MOVED`

Boolean，程序是否判定当次触摸发生了刻意滑动，判断标准 [`MIN_MOVED_DISTANCE`](#min_moved_distance) 。这个值是随触摸位置同步刷新的。

##### `DIRECTIONS_NORMAL`

Array，以 “center”（向屏幕中心），“side”（向屏幕两侧），“up”（向上），“down”（向下）为元素的当次触摸**依次经历的**位移方向的集合。空集表示当次触摸系点击。

##### `DIRECTIONS_THUMB`

Array，以 “centerup”（向屏幕中心且向上），“centerdown”（向屏幕中心且向下），“sideup”（向屏幕两侧且向上），“sidedown”（向屏幕两侧且向下）为元素的当次触摸**依次经历的**位移方向的集合。空集表示当次触摸系点击。

### 动作函数

储存于 `stuff.sh` 中的动作函数。因为载入了该文件，`settings.sh` 内部的[触摸回调函数](#触摸回调函数)可以调用这些动作函数。

#### 类导航栏函数

与导航栏 “三大金刚” 等效。

##### `navigation_back`

返回。

##### `navigation_recents`

显示最近应用。

##### `navigation_home`

回到桌面。

#### 音频操作函数

操控音乐、视频、电影。

##### `media_next`

播放下一个音频，必要时会唤醒音频软件。

##### `media_previous`

播放上一个音频，必要时会唤醒音频软件。

##### `media_pause`

若正在播放音频，则暂停；若无音频正在播放，则无操作；若正在播放的音频被暂停，则无操作。总之，使得设备**不**播放音频。

##### `media_play`

若正在播放音频，则无操作；若无音频正在播放，则唤醒音频软件播放；若正在播放的音频被暂停，则继续。总之，使得设备播放音频。

##### `media_play_pause`

若正在播放音频，则暂停；若无音频正在播放，则唤醒音频软件播放；若正在播放的音频被暂停，则继续。总之，使得设备切换播放状态。

#### **Alpha 实验阶段**函数

作用效果可能因设备而异，可能拥有更好的性能，可能拥有更多的功能，但更可能毫无效用。

##### `screen_touch_relative`

依相对坐标信息点击屏幕相应坐标。

##### `screen_touch_absolute`

依绝对坐标信息点击屏幕相应坐标。

##### `navigation_back_alpha`

点击屏幕导航栏上的返回按键。

##### `navigation_recents_alpha`

点击屏幕导航栏上的最近任务按键。

##### `navigation_home_alpha`

点击屏幕导航栏上的桌面按键。

##### `app_tasker_alpha`

向 Tasker 应用发送 Intent。

## 问题排查

## License

MIT Licensed