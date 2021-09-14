# DSFPagerControl

A simple macOS pager control.

<p align="center">
    <img src="https://img.shields.io/github/v/tag/dagronf/DSFPagerControl" />
    <img src="https://img.shields.io/badge/macOS-10.13+-blue" />
    <img src="https://img.shields.io/badge/Xcode-12+-yellow" />
    <img src="https://img.shields.io/badge/Swift-5.1-orange.svg" />
    <img src="https://img.shields.io/badge/License-MIT-lightgrey" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
</p>

## Why?

I was a bit surprised there isn't a built-in control for displaying a pager (the dots) given macOS has a NSPageController control.

So here's a relatively simple drop-in version.

## Features

* Horizontal or vertical alignments
* Light/Dark mode aware
* High-constrast support
* Delegate feedback support
* Custom color scheme supported
* Optional keyboard selection support
* Optional mouse selection support

## Properties

Many of these properties are `@IBInspectable`, so you can set them directly within interface builder.

| Name                   | Type           | Description                                         |
|:-----------------------|:---------------|:----------------------------------------------------|
| orientation            | `Orientation`  | Is the page control vertically or horizontally oriented? |
| pageCount              | `Int`          | The number of page indicators to display in the control |
| selectedPage           | `Int`          | The current page selection |
| selectedColor          | `NSColor?`     | The color to draw a selected page (nil to use default colors) |
| unselectedColor        | `NSColor?`     | The color to draw an unselected page (nil to use default colors) |
| boundsSize             | `CGSize`       | The size of the page indicator |
| dotSize                | `CGFloat`      | The size of the dot to be displayed in the center of the page indicator |
| allowsKeyboardFocus    | `Bool`         | Allow the user to use the keyboard to focus and change the page selection |
| allowsMouseSelection   | `Bool`         | Allow the user to use the mouse to change the page selection |

## Observables

The following properties are observable.

* `selectedPage`

## Delegate

```swift
func pagerControl(_ pager: DSFPagerControl, willMoveToPage: Int) -> Bool
```

Called when the pager control is asked to change to a new page. You can cancel the change by returning `false`

```swift
func pagerControl(_ pager: DSFPagerControl, didMoveToPage: Int)
```

Called when the pager control has changed to a new page.

## Custom color support

This control provides two block callbacks you can supply to return your own custom colors for selected and unselected states

### selectedColorBlock

Provide a block that returns a custom color to be used when drawing the selected page indicator

### unselectedColorBlock

Provide a block that returns a custom color to be used when drawing the unselected page indicator

## Releases

### 1.0.0

* Initial release

## License

MIT. Use it and abuse it for anything you want, just attribute my work. Let me know if you do use it somewhere, I'd love to hear about it!

```
MIT License

Copyright (c) 2021 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
