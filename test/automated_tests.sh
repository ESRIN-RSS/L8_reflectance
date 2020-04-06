#!/bin/bash

# define the exit codes
SUCCESS=0
ERR=1

# add a trap to exit gracefully
function cleanExit() {
  local retval=$?
  local msg=""

  case ${retval} in
  ${SUCCESS}) msg="Test successfully concluded" ;;
  ${ERR}) msg="Test failed" ;;
  *) msg="Unknown error" ;;
  esac
  [ ${retval} -ne 0 ] && echo "Error ${retval} - ${msg}, processing aborted" || echo "${msg}"
  exit ${retval}
}

trap cleanExit EXIT

function run_l8_reflectance() {

  local img=$1
  L8_reflectance ${img} $( dirname ${img})

  [ ! -d "${img}_TOA" ] && exit 1

  for entry in "${img}"/*.TIF; do
    img_file=$(basename "$entry")
    if [[ ! ${img_file} == *_B[8-9].TIF && ! ${img_file} == *_BQA.TIF ]]; then
      img_toa="${img_file//.TIF/_TOA.TIF}"
      img_toa="${img}_TOA/${img_toa}"
      [ ! -f "${img_toa}" ] && exit 1
    fi
  done
}

function main() {
  #download sample image:
  sample_img_url=http://storage.googleapis.com/gcp-public-data-landsat/LC08/PRE/203/031/LC82030312015026LGN00
  sample_img=LC82030312015026LGN00
  mkdir ${sample_img}
  # Declare an array of string with type
  declare -a StringArray=("B1.TIF", "B2.TIF", "B3.TIF", "B4.TIF", "B5.TIF",
                          "B6.TIF", "B7.TIF", "B8.TIF", "B9.TIF", "B10.TIF",
                          "B11.TIF", "BQA.TIF", "MTL.txt" )

  # Iterate the string array using for loop
  for val in ${StringArray[@]}; do
     wget -q "${sample_img_url}/${sample_img}_${val//,/}" -P ${sample_img}
  done
  run_l8_reflectance $sample_img
  [ $? -eq 0 ] || return ${ERR}
}

main

exit ${SUCCESS}