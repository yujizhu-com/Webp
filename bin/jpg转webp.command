#!/bin/bash

function Clear_Befor_Chars()
{
    echo "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\c"
}

to_detect_dir_count=0
function Counter_Dir()
{
    local file_absolute_dir
    for file in $(ls -a $1)
    do
        file_absolute_dir=$1"/"$file
        if [ -d "$file_absolute_dir" ]
        then
            local ignore_dir=0
                
            if [[ $file =~ ^[.,..]+ ]]
            then
                ignore_dir=1
#            elif [[ $file =~ $dir_regexp_ignore_set ]]
#            then
#                ignore_dir=1
#                echo "\t忽略路径:"$file_absolute_dir
            fi
            
            if [ $ignore_dir == 0 ]
            then
                ((++to_detect_dir_count))
                echo "\t待扫描路径:"$to_detect_dir_count"\c"
                Clear_Befor_Chars
                Counter_Dir $file_absolute_dir
            fi
        fi
    done
}

# 31 black,37 white

color_set=(31 32 33 34 35 36)
color_count=${#color_set[*]}
color_max_i=$((color_count-1))

#dir_regexp_ignore_set='^[*,#,^,-]+'
file_regexp_ignore_set='^([.].*)'
detected_dir_count=0
function Read_Dir()
{
    for file in $(ls -a $1)
    do
        absoluteFileDir=$1"/"$file
    
        if [ -d "$absoluteFileDir" ]
        then
            local ignore_dir=0
                
            if [[ $file =~ ^[.,..]+ ]]
            then
                ignore_dir=1
#            elif [[ $file =~ $dir_regexp_ignore_set ]]
#            then
#                ignore_dir=1
            fi
            
            if [ $ignore_dir == 0 ]
            then
                ((++detected_dir_count))
                echo "\t查找进度:"`echo "scale=5;$detected_dir_count/$to_detect_dir_count*100" | bc`"%\c"
                Clear_Befor_Chars
                Read_Dir $absoluteFileDir
            fi
        else
            local need_ignore_file=0
            if [[ $file =~ $file_regexp_ignore_set ]]
            then
                need_ignore_file=1
                echo "\t忽略文件:"$absoluteFileDir
            fi
            
            if [[ $need_ignore_file == 0 ]]
            then
                jpg2webp "$file" "$1"
                png2webp "$file" "$1"
            fi
        fi
    done
}

function jpg2webp()
{
    local file=$1
    if [[ $file =~ \.jpg$ ]]
    then
        local webp_file=${file/%jpg/webp}
        local dir=$0
        dir=${dir%/*}
        $dir/cwebp -q 70 $2"/"$file -o $2"/"$webp_file
        rm $2"/"$file
    fi
}

function png2webp()
{
    local file=$1
    if [[ $file =~ \.png$ ]]
    then
        local webp_file=${file/%png/webp}
        local dir=$0
        dir=${dir%/*}
        $dir/cwebp -q 70 $2"/"$file -o $2"/"$webp_file
        rm $2"/"$file
    fi
}


function main()
{
    echo "\n\t------ 开始转换 ------\n"
    Counter_Dir $1
    echo "\n"
    Read_Dir $1
    echo "\n"
    echo ${all_to_convert_files[*]}
    echo "\n\t------ 转换结束 ------\n"
}

read -p 输入目标路径: TARGET_DIR

main "$TARGET_DIR"

