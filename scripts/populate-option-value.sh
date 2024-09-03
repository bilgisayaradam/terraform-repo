

#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SOURCE_YAML_FILE="$SCRIPT_DIR/../.github/workflows/manual_terraform.yml"
USECASE_DIRECTORY="$SCRIPT_DIR/../usecases/"

# dynamically generate values.
# ex. could read repository or file to get values
OPTIONS=`ls $USECASE_DIRECTORY`
 
 

current_options=$(yq eval '.on.workflow_dispatch.inputs.use_case.options' $SOURCE_YAML_FILE )
  
current_options_array=()
while read -r word; do
    current_options_array+=("$word")
done <<< "$current_options"
 
declare -a output_array=()
declare -a output_array1=()

for i in $OPTIONS; do
 
    output_array+=("- '$i'")
    output_array1+=("$i")
done


# Check if the values in the arrays are equal
echo ${current_options_array[*]} one
echo ${output_array[*]} two
if [[ "${current_options_array[*]}" == "${output_array[*]}" ]]; then
    echo "Values in YAML file are equal to values in array. No update needed."
else
    echo "Values in YAML file are not equal to values in array. Updating YAML file."
    # Construct YAML-compatible string
    options_string="["

    for option in "${output_array1[@]}"; do
    echo $option
        options_string+="\"$option\", "
       
    done

    options_string="${options_string%, }]"
 
    echo $options_string
    #yq -o y .on.workflow_dispatch.inputs.version.options $SOURCE_YAML_FILE
    yq eval ".on.workflow_dispatch.inputs.use_case.options = $options_string" $SOURCE_YAML_FILE > temp.yml && mv temp.yml $SOURCE_YAML_FILE
fi

