#!/bin/bash

config="./sourcesetr.config"

# NOTE (@philsinatra): Need to sort the input numeric values because
# the HTML5 picture element sourceset requires the dimensions to be
# coded in descending order.
# REFERENCE: https://unix.stackexchange.com/questions/247655/how-to-create-a-function-that-can-sort-an-array-in-bash
sort () {
    for ((i=0; i <= $((${#arr[@]} - 2)); ++i))
    do
        for ((j=((i + 1)); j <= ((${#arr[@]} - 1)); ++j))
        do
            if [[ ${arr[i]} -lt ${arr[j]} ]]
            then
                # echo $i $j ${arr[i]} ${arr[j]}
                tmp=${arr[i]}
                arr[i]=${arr[j]}
                arr[j]=$tmp
            fi
        done
    done
}

while getopts ":c" opt; do
  case $opt in
    c)
      echo ""
      echo ""
      echo "**********************************************"
      echo "* Creating SourceSetr config file..."
      echo "* Enter the 'width' values you want to include"
      echo "* in the config file."
      echo "* Seperate each value with a space."
      echo ""
      echo "* Example: "
      echo "1200 600 300"
      echo "**********************************************"

      read -p "SourceSetr Width Values: " -a arr
      sort ${arr[@]}
      # Show array length
      # echo ${#arr[@]}

      for i in ${arr[@]}
      do
        input_values="$input_values $i"
      done

      # NOTE (@philsinatra): Need to clean up the first instance of a space in
      # the input values so the final output is formatted correctly.
      # REFERENCE: https://stackoverflow.com/questions/5928156/replace-a-space-with-a-period-in-bash
      clean_input_values=${input_values/ /}

      sizes="sizes=($clean_input_values)"
      echo $sizes > $config
      echo "sourcesetr.config established:"
      echo "$sizes"
      echo ""

      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done


i=0
sizes=(1800 1600 1200 900 600 300 100)
instance="`date +%Y%m%d%H%M%S`"
export_location=exports-"$instance"
details="$export_location"/-sourcesetr.txt


if [ -f "$config" ];
then
  source $config
else
  echo 'sizes=(1800 1600 1200 900 600 300 100)' > $config
fi

mkdir -p $export_location
echo -e "Sourcesetr\n" > $details


find . -name '*.jpg' -maxdepth 1 | while IFS= read -r FILE;
do
  basename=${FILE##*/}
  filename="${basename%.*}"
  echo "<picture>" >> $details
  while [ $i -lt ${#sizes[@]} ];
  do
    echo "  <source media=\"(min-width: ${sizes[$i]}px)\" srcset=\"$filename-${sizes[$i]}.jpg 1x, $filename-${sizes[$i]}@2x.jpg 2x\">" >> $details

    cp "$basename" $export_location/"$filename"-${sizes[$i]}.jpg
    sips -Z ${sizes[$i]} $export_location/"$filename"-${sizes[$i]}.jpg
    cp "$basename" $export_location/"$filename"-${sizes[$i]}@2x.jpg
    sips -Z "$((${sizes[$i]} * 2))" $export_location/"$filename"-${sizes[$i]}@2x.jpg
    : $[ i++ ]
  done
  echo "  <img src=\"$filename.jpg\" alt=\"\">" >> $details
  echo "</picture>" >> $details
  echo -e "\n" >> $details
  i=0
done
i=0


find . -name '*.png' -maxdepth 1 | while IFS= read -r FILE;
do
  basename=${FILE##*/}
  filename="${basename%.*}"
  echo "<picture>" >> $details
  while [ $i -lt ${#sizes[@]} ];
  do
    echo "  <source media=\"(min-width: ${sizes[$i]}px)\" srcset=\"$filename-${sizes[$i]}.png 1x, $filename-${sizes[$i]}@2x.png 2x\">" >> $details

    cp "$basename" $export_location/"$filename"-${sizes[$i]}.png
    sips -Z ${sizes[$i]} $export_location/"$filename"-${sizes[$i]}.png
    cp "$basename" $export_location/"$filename"-${sizes[$i]}@2x.png
    sips -Z "$((${sizes[$i]} * 2))" $export_location/"$filename"-${sizes[$i]}@2x.png
    : $[ i++ ]
  done
  echo "  <img src=\"$filename.png\" alt=\"\">" >> $details
  echo "</picture>" >> $details
  echo -e "\n" >> $details
  i=0
done
