#!/bin/bash

# Xcodeプロジェクトにファイルを自動追加するスクリプト
# 使用方法: ./add_files_to_xcode.sh [ファイルパス]

PROJECT_FILE="mytimetablemaker_swiftui.xcodeproj/project.pbxproj"
PROJECT_NAME="mytimetablemaker_swiftui"

if [ $# -eq 0 ]; then
    echo "使用方法: $0 [ファイルパス]"
    echo "例: $0 mytimetablemaker_swiftui/NewFile.swift"
    exit 1
fi

FILE_PATH="$1"
FILE_NAME=$(basename "$FILE_PATH")
FILE_EXTENSION="${FILE_NAME##*.}"

# ファイルタイプの判定
case "$FILE_EXTENSION" in
    "swift")
        FILE_TYPE="sourcecode.swift"
        ;;
    "xcconfig")
        FILE_TYPE="text.xcconfiguration"
        ;;
    "plist")
        FILE_TYPE="text.plist.xml"
        ;;
    "strings")
        FILE_TYPE="text.plist.strings"
        ;;
    "entitlements")
        FILE_TYPE="text.plist.entitlements"
        ;;
    "storyboard")
        FILE_TYPE="file.storyboard"
        ;;
    "xib")
        FILE_TYPE="file.xib"
        ;;
    "xcassets")
        FILE_TYPE="folder.assetcatalog"
        ;;
    "xcdatamodeld")
        FILE_TYPE="wrapper.xcdatamodel"
        ;;
    "xcdatamodel")
        FILE_TYPE="wrapper.xcdatamodel"
        ;;
    "otf"|"ttf")
        FILE_TYPE="file"
        ;;
    *)
        FILE_TYPE="text"
        ;;
esac

# 新しいUUIDを生成
NEW_UUID=$(uuidgen | tr '[:lower:]' '[:upper:]' | sed 's/-//g')

# ファイル参照を追加
echo "プロジェクトファイルにファイル参照を追加中..."
sed -i '' "/\/\* End PBXFileReference section \*\//i\\
		${NEW_UUID} /* ${FILE_NAME} */ = {isa = PBXFileReference; lastKnownFileType = ${FILE_TYPE}; path = ${FILE_NAME}; sourceTree = \"<group>\"; };
" "$PROJECT_FILE"

# プロジェクトグループにファイルを追加
echo "プロジェクトグループにファイルを追加中..."
sed -i '' "/children = (/a\\
					${NEW_UUID} /* ${FILE_NAME} */,
" "$PROJECT_FILE"

echo "ファイル '$FILE_PATH' をXcodeプロジェクトに追加しました。"
echo "UUID: $NEW_UUID"
echo "ファイルタイプ: $FILE_TYPE" 