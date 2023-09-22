#!/bin/bash

# Exit script if any subcommands fail
set -e

function hyphen_to_snake_case() {
    echo $1 | tr '[:upper:]' '[:lower:]' | tr '-' '_'
}

function run_test() {
    exercises_path="exercises/practice"
    meta=".meta"
    exercise_name="${1}"
    exercise_path="${exercises_path}/${exercise_name}"
    
    if [ -n "${exercise_name}" ] && [ -d "${exercise_path}" ]; then
        echo "Running test for exercise: ${exercise_name}"
    
        # Turn something like "hello-world" into "hello_world"
        exercise_safe_name=$(hyphen_to_snake_case ${exercise_name})
    
        # "exercises/practice/hello_world.odin"
        solution_file="${exercise_path}/${exercise_safe_name}.odin"
    
        # "exercises/practice/hello_world_test.odin"
        test_file="${exercise_path}/${exercise_safe_name}_test.odin"
    
        # "exercises/practice/.meta/hello_world_example.odin"
        example_file="${exercise_path}/${meta}/${exercise_safe_name}_example.odin"
    
        # Move the blank solution file into the meta directory for a bit
        mv ${solution_file} ${exercise_path}/${meta}
    
        # Copy the example file into the main directory
        cp ${example_file} ${solution_file}
    
        # Run the tests using the example file
        odin test ${exercise_path}
    
        # Move the blank solution file back into the main directory
        mv "${exercise_path}/${meta}/${exercise_safe_name}.odin" ${solution_file}

        # Remove the built executable
        rm -f ${exercise_name}
    else
        echo "Running all tests"
        for exercise in $(ls $exercises_path)
        do
            run_test $exercise
        done
    fi
}

run_test $@