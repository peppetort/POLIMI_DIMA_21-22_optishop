#!/bin/bash

set -e
# set -x



images_src_dir='images_src/'
images=${images_src_dir}*.png
assets_images_base_dir='assets/images/'

images=$(git ls-files -o -m images_src/)

if [ "$1" == "-f" ]; then
  images=${images_src_dir}*.png
fi
# if [ -n "$(git status images_src/ --porcelain)" ]; then
if [ -n "$images" ]; then
  for image in $images; do
      file=${image##*/}
      echo "convert $image"
      width=$(sips -g "pixelWidth" "$image" | awk 'FNR>1 {print $2}')
      height=$(sips -g "pixelHeight" "$image" | awk 'FNR>1 {print $2}')
      width_1x=`echo "scale=0 ; $width/4" | bc`
      width_1_5x=`echo "scale=0 ; ($width/4)*1.5" | bc`
      width_2x=`echo "scale=0 ; ($width/4)*2" | bc`
      width_3x=`echo "scale=0 ; ($width/4)*3" | bc`
      width_4x=`echo "scale=0 ; $width" | bc`

      sips --resampleWidth "$width_1x" $image --out ${assets_images_base_dir}$file
      sips --resampleWidth "$width_1_5x" $image --out ${assets_images_base_dir}1.5x/$file
      sips --resampleWidth "$width_2x" $image --out ${assets_images_base_dir}2.0x/$file
      sips --resampleWidth "$width_3x" $image --out ${assets_images_base_dir}3.0x/$file
      cp $image ${assets_images_base_dir}4.0x/$file
  done
else
  echo "no changes";
fi


