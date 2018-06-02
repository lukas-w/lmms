_SCRIPT="$BASH_SOURCE"
_DIR=$(dirname "$_SCRIPT")
source "$_DIR/common.sh"

if [ -z "$SOURCE_DIR" ]; then
	SOURCE_DIR=$(pwd)
fi

if [ -z "$BUILD_DIR" ]; then
	BUILD_DIR="$SOURCE_DIR/build"
fi

function parentimages() {
	local img=$1
	local parent_img=""
	for img_part in ${img//-/ }; do
		if [[ "$parent_img" ]]; then
			parent_img="$parent_img-$img_part"
		else
			parent_img="$img_part"
		fi
		echo $parent_img
	done
}
