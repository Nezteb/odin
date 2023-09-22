#!/bin/bash

# Exit script if any subcommands fail
set -e

function hyphen_to_snake_case() {
    echo $1 | tr '[:upper:]' '[:lower:]' | tr '-' '_'
}

exercises_path="exercises/practice"
meta=".meta"
exercise_name="${1}"
exercise_path="${exercises_path}/${exercise_name}"

if [ -z "${exercise_name}" ]; then
    echo "Must give an exercise name to generate"
elif [ -d "${exercise_path}" ]; then
    echo "Exercise already exists: ${exercise_name}"
elif [ -n "${exercise_name}" ]; then
    echo "Generating test for exercise: ${exercise_name}"
    
    bin/configlet sync --update --yes --docs --metadata --exercise ${exercise_name}
    bin/configlet sync --update --tests include --exercise ${exercise_name}

    # Turn something like "hello-world" into "hello_world"
    exercise_safe_name=$(hyphen_to_snake_case ${exercise_name})

    # "exercises/practice/hello_world.odin"
    solution_file="${exercise_path}/${exercise_safe_name}.odin"

    # "exercises/practice/hello_world_test.odin"
    test_file="${exercise_path}/${exercise_safe_name}_test.odin"

    # "exercises/practice/.meta/hello_world_example.odin"
    example_file="${exercise_path}/${meta}/${exercise_safe_name}_example.odin"

    cat > ${solution_file} <<EOL
package $exercise_safe_name

$exercise_safe_name :: proc() -> string {
	return ""
}
EOL

    cat > ${test_file} <<EOL
package $exercise_safe_name

import "core:testing"

@(test)
test :: proc(t: ^testing.T) {
	expected := "Some value"

	testing.expect_value(t, $exercise_safe_name(), expected)
}
EOL

    cp ${solution_file} ${example_file}

    echo "Be sure to implement the following files:"
    echo -e "\t${solution_file}"
    echo -e "\t${test_file}"
    echo -e "\t${example_file}"
    echo ""
    
    echo "Running configlet lint:"
    bin/configlet lint
fi