//
//  ContentView.swift
//  Pager SwiftUI Demo
//
//  Created by Darren Ford on 20/7/2024.
//

import SwiftUI
import DSFPagerControl

struct ContentView: View {
	@State var selection = 3
	@State var pageCount = 10

	@State var drawBorder = false

	var body: some View {
		VStack {
			ScrollViewReader { value in
				ScrollView(.horizontal) {
					LazyHStack {
						ForEach(0 ..< pageCount, id: \.self) { i in
							RoundedRectangle(cornerRadius: 25)
								.fill(Color(hue: Double(i) / Double(pageCount), saturation: 1, brightness: 1).gradient)
								.frame(width: 100, height: 100)
								.id(i)
						}
					}
					.scrollTargetLayout()
				}
				.scrollTargetBehavior(.viewAligned)
				.scrollDisabled(true)
				.frame(width: 100, height: 120)
				.onChange(of: selection) { oldValue, newValue in
					withAnimation(.bouncy(duration: 2)) {
						value.scrollTo(newValue, anchor: .center)
					}
				}
				.onAppear {
					value.scrollTo(selection, anchor: .top)
				}
			}

			HStack {

				VStack(spacing: 4) {
					DSFPagerControlUI(
						pageCount: pageCount,
						selectedPage: $selection,
						allowsMouseSelection: true,
						bordered: drawBorder
					)

					DSFPagerControlUI(
						pageCount: pageCount,
						selectedPage: $selection,
						allowsMouseSelection: true,
						selectedColor: Color.red,
						unselectedColor: Color.blue.opacity(0.2),
						bordered: drawBorder
					)

					Text("Selected page: \(selection + 1)")
					Text("Page Count: \(pageCount)")

					Button {
						drawBorder.toggle()
					} label: {
						Text("Toggle borders")
					}

					Button {
						selection = 0
						pageCount += 1
					} label: {
						Text("Reset")
					}
					Spacer()
				}

				DSFPagerControlUI(
					orientation: .vertical,
					pageCount: pageCount,
					selectedPage: $selection,
					allowsKeyboardSelection: true,
					selectedColor: .green,
					unselectedColor: .green.opacity(0.1),
					bordered: drawBorder
				)
			}
		}
		.padding()
	}
}

#Preview {
	ContentView()
}
