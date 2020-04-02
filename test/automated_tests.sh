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
  fels 203031 OLI_TIRS 2015-01-01 2015-06-30 -c 30 -o LANDSAT --latest --outputcatalogs /tmp --overwrite
  img='LANDSAT/LC08_L1TP_203031_20150518_20170409_01_T1'
  run_l8_reflectance $img
  [ $? -eq 0 ] || return ${ERR}
}

main

exit ${SUCCESS}