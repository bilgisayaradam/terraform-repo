

#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
MANUAL_TERRAFORM_YML="$SCRIPT_DIR/../.github/workflows/manual_terraform.yml"
USECASE_DIRECTORY="$SCRIPT_DIR/../usecases/"

OPTIONS=`ls $USECASE_DIRECTORY`
 
 

current_options=$(yq eval '.on.workflow_dispatch.inputs.use_case.options' $MANUAL_TERRAFORM_YML )
  
current_options_array=()
while read -r word; do
    current_options_array+=("$word")
done <<< "$current_options"
 
declare -a tmp_output_array=()
declare -a target_output_array=()

for i in $OPTIONS; do
 
    tmp_output_array+=("- $i")
    target_output_array+=("$i")
done


# Check if the values in the arrays are equal
echo ${current_options_array[*]} current values
echo ${tmp_output_array[*]} new values
if [[ "${current_options_array[*]}" == "${tmp_output_array[*]}" ]]; then
    echo "Values in YAML file are equal to values in array. No update needed."
else
    echo "Values in YAML file are not equal to values in array. Updating YAML file."
    # Construct YAML-compatible string
    options_string="["

    for option in "${target_output_array[@]}"; do
    echo $option
        options_string+="\"$option\", "
    done

    options_string="${options_string%, }]"
 
    echo $options_string
    #yq -o y .on.workflow_dispatch.inputs.version.options $SOURCE_YAML_FILE
    yq eval ".on.workflow_dispatch.inputs.use_case.options = $options_string" $MANUAL_TERRAFORM_YML > temp.yml && mv temp.yml $MANUAL_TERRAFORM_YML
fi

