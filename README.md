# DSFPagerControl

<p align="center">
   <img src="./art/dark.png?raw=true" width="130" />&nbsp;
   <img src="./art/light.png?raw=true" width="130" />
</p>


<p align="center">A simple macOS pager control.</p>

<p align="center">
    <img src="https://img.shields.io/github/v/tag/dagronf/DSFPagerControl" />
    <img src="https://img.shields.io/badge/macOS-10.11+-blue" />
    <img src="https://img.shields.io/badge/Xcode-12+-yellow" />
    <img src="https://img.shields.io/badge/Swift-5.1-orange.svg" />
    <img src="https://img.shields.io/badge/License-MIT-lightgrey" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
</p>

## Why?

I was a bit surprised there isn't a built-in control for displaying a pager (the dots) given macOS has a NSPageController control.

So here's a relatively simple packaged drop-in version.

## Features

* Horizontal or vertical alignments
* Light/Dark mode aware
* High-constrast support
* Delegate feedback support
* Custom color scheme supported
* Optional keyboard selection support
* Optional mouse selection support

The control is designed to be driven by :- 
* Direct interaction, for example using to drive the visible page of a theme selector.
* Purely display, for example displaying the current page being displayed in an `NSPageController` instance
* … or a combination of both! 

## Installation

Using Swift Package Manager, add `https://github.com/dagronf/DSFPagerControl` to your project.

## Properties

Many of these properties are `@IBInspectable` so you can set them directly within interface builder when Apple fixes IBDesignable support for packaged NSViews (Boooo! - its only been five years - FB8358478).

If you copy the package source files into your project IBDesignables will show as expected.

| Name                     | Type           | Description                                         |
|:-------------------------|:---------------|:----------------------------------------------------|
| orientation              | `Orientation`  | Is the page control vertically or horizontally oriented? |
| pageCount                | `Int`          | The number of page indicators to display in the control |
| selectedPage             | `Int`          | The current page selection (Observable) |
| selectedColor            | `NSColor?`     | The color to draw a selected page (nil to use default colors) |
| unselectedColor          | `NSColor?`     | The color to draw an unselected page (nil to use default colors) |
| boundsSize               | `CGSize`       | The size of the page indicator |
| dotSize                  | `CGFloat`      | The size of the dot to be displayed in the center of the page indicator |
| allowsKeyboardSelection  | `Bool`         | Allow the user to use the keyboard to focus and change the page selection |
| allowsMouseSelection     | `Bool`         | Allow the user to use the mouse to change the page selection |

## Observables

These are member variables you can observe for changes

| Name                     | Type     | Description                          |
|:-------------------------|:---------|:-------------------------------------|
| pageCount                | `Int`    | The number of pages                  |
| selectedPage             | `Int`    | The selected page                    |
| isFirstPage              | `Bool`   | Is the selection the first page?     |
| isLastPage               | `Bool`   | Is the selection the last page?      |

## Delegate

```swift
func pagerControl(_ pager: DSFPagerControl, willMoveToPage page: Int) -> Bool
```

Called when the user attempts to change the selection of the pager control is asked to change to a new page. You can deny the page change by returning `false`

Note this is only called when allowsKeyboardFocus

```swift
func pagerControl(_ pager: DSFPagerControl, didMoveToPage page: Int)
```

Called when the pager control has changed to a new page.

## User interaction

The control optionally supports keyboard and mouse interactions. When the user interacts with the control you can decide whether to perform the change via the use of a delegate.

### Keyboard

When `allowsKeyboardSelection` is true, the control will accept focus events and reacts to the following keys :-

* Up/Left: Move to the previous page
* Down/Right: Move to the next page

When a key is pressed, the delegate is called (`willMoveToPage`) to ask whether the change is valid. If so, the pager will update its display and call `didMoveToPage` on the delegate.

### Mouse

When `allowsMouseSelection` is true, the cursor will change to a hand when its over the control.  

When the user clicks a page indicator, the delegate is called (`willMoveToPage`) to ask whether the change is valid. If so, the pager will update its display and call `didMoveToPage` on the delegate. 

## Custom color support

By default, DSFPagerControl supplies a standard color palette, adapting automatically to the user's light/dark modes and contrast settings.

If you want to customize your display, the control provides two block callbacks you can supply to return your own custom colors for selected and unselected states.

### selectedColorBlock

Provide a block that returns a custom color to be used when drawing the selected page indicator.

### unselectedColorBlock

Provide a block that returns a custom color to be used when drawing the unselected page indicator.

## License

MIT. Use it and abuse it for anything you want, just attribute my work. Let me know if you do use it somewhere, it'd be great to hear about it!

```
MIT License

Copyright (c) 2024- Darren Ford

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
