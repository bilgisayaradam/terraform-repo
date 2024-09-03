

#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
MANUAL_TERRAFORM_YML="$SCRIPT_DIR/../.github/workflows/manual_terraform.yml"
WORKFLOWS_DIR="$SCRIPT_DIR/../.github/workflows"
USECASE_DIRECTORY="$SCRIPT_DIR/../usecases/"

OPTIONS=`ls $USECASE_DIRECTORY`
 
for WORKFLOW in `ls $WORKFLOWS_DIR`
do

    if [[ `yq '.on.workflow_dispatch.inputs.use_case.options' $WORKFLOWS_DIR/$WORKFLOW` != 'null' ]]; then
        
        current_options=$(yq eval '.on.workflow_dispatch.inputs.use_case.options' $WORKFLOWS_DIR/$WORKFLOW )
    else
        echo "skipping $WORKFLOW no options to update"
        continue
    fi

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
echo "Processing $WORKFLOWS_DIR/$WORKFLOW"
if [[ "${current_options_array[*]}" == "${tmp_output_array[*]}" ]]; then
    echo "Values in YAML file are equal to values in array. No update needed."
else
    echo "Values in YAML file are not equal to values in array. Updating YAML file."
    # Construct YAML-compatible string
    options_string="["

    for option in "${target_output_array[@]}"; do
        options_string+="\"$option\", "
    done

    options_string="${options_string%, }]"
    yq eval ".on.workflow_dispatch.inputs.use_case.options = $options_string" $WORKFLOWS_DIR/$WORKFLOW  > temp.yml && mv temp.yml $WORKFLOWS_DIR/$WORKFLOW 
fi
done