/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include "ABI39_0_0ImageManager.h"

#import <ABI39_0_0React/ABI39_0_0RCTImageLoaderWithAttributionProtocol.h>
#import <ABI39_0_0React/ABI39_0_0RCTUtils.h>
#import <ABI39_0_0React/utils/ManagedObjectWrapper.h>

#import "ABI39_0_0RCTImageManager.h"
#import "ABI39_0_0RCTSyncImageManager.h"

namespace ABI39_0_0facebook {
namespace ABI39_0_0React {

ImageManager::ImageManager(ContextContainer::Shared const &contextContainer)
{
  id<ABI39_0_0RCTImageLoaderWithAttributionProtocol> imageLoader =
      (id<ABI39_0_0RCTImageLoaderWithAttributionProtocol>)unwrapManagedObject(
          contextContainer->at<std::shared_ptr<void>>("ABI39_0_0RCTImageLoader"));
  if (ABI39_0_0RCTRunningInTestEnvironment()) {
    self_ = (__bridge_retained void *)[[ABI39_0_0RCTSyncImageManager alloc] initWithImageLoader:imageLoader];
  } else {
    self_ = (__bridge_retained void *)[[ABI39_0_0RCTImageManager alloc] initWithImageLoader:imageLoader];
  }
}

ImageManager::~ImageManager()
{
  CFRelease(self_);
  self_ = nullptr;
}

ImageRequest ImageManager::requestImage(const ImageSource &imageSource, SurfaceId surfaceId) const
{
  ABI39_0_0RCTImageManager *imageManager = (__bridge ABI39_0_0RCTImageManager *)self_;
  return [imageManager requestImage:imageSource surfaceId:surfaceId];
}

} // namespace ABI39_0_0React
} // namespace ABI39_0_0facebook
