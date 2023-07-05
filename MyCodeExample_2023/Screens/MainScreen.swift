//
//  ContentView.swift
//  MyCodeExample_2023
//
//  Created by Алексей Чигарских on 05.07.2023.
//

import SwiftUI
import HalfASheet
import Container
import Combine

//MARK: This is exemple of my code( Photo editor main view)
struct MainScreen: View {
    
    @ObservedObject var viewModel : MainScreenViewModel
    private var horizontalPaddingX2: CGFloat = 40
    
    init(viewModel: MainScreenViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Color(hex: "F5F5F5", opacity: 1.0)
                    .ignoresSafeArea()
                VStack {
                        if viewModel.originalChoosenImage != nil {
                            TopButtonsView(changeSizeAction: {
                                viewModel.showResolutionView = ()
                            }, closeAction: {
                                viewModel.closeCurrentImage()
                            })
                            .frame(width: geometry.size.width - horizontalPaddingX2 ,alignment: .center)
                    }
                    HStack {
                        if viewModel.choosenImage != nil {
                            Spacer()
                            ZStack {
                                ImgEditorView(viewModel: viewModel, geometry: geometry, angle: $viewModel.angle, onTapShare: $onTapShare)
                                    .frame(width: UIScreen.screenWidth - horizontalPaddingX2, height: UIScreen.screenHeight - 400, alignment: .center)
                            }
                            Spacer()
                        } else {
                            Spacer()
                            _EmptyView()
                                .frame(width: UIScreen.screenWidth - horizontalPaddingX2, height: UIScreen.screenHeight - 400, alignment: .center)
                                .clipped()
                                .onTapGesture {
                                    viewModel.onTapChoosePhoto = ()
                                }
                            Spacer()
                        }
                    }.contentShape(Rectangle())
                        .padding(.top, viewModel.originalChoosenImage != nil ? 0 : 30)
                    
                    Spacer()
                    
                    if viewModel.choosenImage == nil {
                        SelectPhotoButton {
                            print("select photo")
                            viewModel.onTapChoosePhoto = ()
                        }
                    } else {
                        if !viewModel.presentCompressView  {
                            Carousel(cropFactor: $viewModel.cropFactor_standart, onTapExtendedCropFactors: $viewModel.onTapExtendedCropFactors, currentAngle: $viewModel.angle)
                                .noPadding()
                                .padding(.bottom, 20)
                        } else {
                            QualityView(quality: $viewModel.imageQuality, fileSize: $viewModel.fileSize)
                                .onAppear() {
                                    viewModel.calculateImageFileSize()
                                }
                            .noPadding()
                            .padding(.bottom, 20)
                        }
                        
                        BottomButtonsView(onTapShare: $onTapShare, presentCompressView: $viewModel.presentCompressView) {
                            viewModel.onTapCompress = ()
                        }
                    }
                }
            }
            //MARK: ResolutionView
            HalfASheet(isPresented: $viewModel.presentResolutionView, title: "") {
                ResolutionView(imageSize: $viewModel.choosenImage) {newSize in
                    viewModel.onTapSaveNewResolution = newSize
                }
                        }
                        .height(.fixed(250 + keyboardHeight)) //correnct is 250 + keyboard
                        .closeButtonColor(.white)
                        .backgroundColor(.white)
                        .ignoresSafeArea()

            //MARK: Extended crop factors
            HalfASheet(isPresented: $viewModel.presentExtendedCropFactors, title: "") {
                ExtendedCropFactors(cropFactor_extended: $viewModel.cropFactor_extended, selectedCategory: $viewModel.selectedCropCategory)
                    .frame(width: UIScreen.screenWidth)
                        }
            .contentInsets(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
            .height(.proportional(0.55))
                        .closeButtonColor(UIColor(Color(hex: "F5F5F5", opacity: 1.0)))
                        .backgroundColor(UIColor(Color(hex: "F5F5F5", opacity: 1.0)))
                        .ignoresSafeArea()
             
        }.onReceive(Publishers.keyboardHeight) {
            self.keyboardHeight = $0
        }.onChange(of: viewModel.cropFactor_standart) { newValue in
            //Set image to default
            if newValue == .original {
                viewModel.choosenImage = viewModel.originalChoosenImage
            }
            viewModel.selectedCropCategory = .standart
            viewModel.cropFactor_extended = newValue
        }
    }
}

struct MainScrenn_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen(viewModel: MainScreenViewModel())
    }
}

