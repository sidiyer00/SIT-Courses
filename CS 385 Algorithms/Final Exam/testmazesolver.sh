#!/bin/bash

file=mazesolver.cpp

if [ ! -f "$file" ]; then
    echo -e "Error: File '$file' not found.\nTest failed."
    exit 1
fi

num_right=0
total=0
line="________________________________________________________________________"
compiler=
interpreter=
language=
extension=${file##*.}
if [ "$extension" = "py" ]; then
    if [ ! -z "$PYTHON_PATH" ]; then
        interpreter=$(which python.exe)
    else
        interpreter=$(which python3.2)
    fi
    command="$interpreter $file"
    echo -e "Testing $file\n"
elif [ "$extension" = "java" ]; then
    language="java"
    command="java ${file%.java}"
    echo -n "Compiling $file..."
    javac $file
    echo -e "done\n"
elif [ "$extension" = "c" ] || [ "$extension" = "cpp" ]; then
    language="c"
    command="./${file%.*}"
    echo -n "Compiling $file..."
    results=$(make 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "\n$results"
        exit 1
    fi
    echo -e "done\n"
fi

run_test_args() {
    (( ++total ))
    echo -n "Running test $total..."
    expected=$2
    received=$( $command $1 2>&1 | tr -d '\r' )
    if [ "$expected" = "$received" ]; then
        echo "success"
        (( ++num_right ))
    else
        echo -e "failure\n\nExpected$line\n$expected\nReceived$line\n$received\n"
    fi
}

run_test_args "" "Usage: ./mazesolver <maze file>"
run_test_args "no_maze.txt" "Error: File 'no_maze.txt' not found."

(cat << EOF
EOF
) > maze.txt
run_test_args "maze.txt" "Error: File 'maze.txt' is empty."

(cat << EOF
###############
#   # # #     #
# ### # ##### #
# # # # #     #
# # # # # # ###
#         #   #
# ### ####### #
#   # #       #
# # # # # # # #
###############
EOF
) > maze.txt
run_test_args "maze.txt" "Error: Maze has no openings."
rm -f maze.txt

(cat << EOF
###############
#   # # #     #
# ### # ##### #
# # # # #     #
# # # # # # ###
          #   #
# ### ####### #
#   # #       #
# # # # # # # #
###############
EOF
) > maze.txt
run_test_args "maze.txt" "Error: Maze has only 1 opening."
rm -f maze.txt

(cat << EOF
############ ##
#   # # #     #
# ### # ##### #
# # # # #     #
# # # # # # ###
          #   #
# ### ####### #
#   # #       #
# # # # # # # #
########## ####
EOF
) > maze.txt
run_test_args "maze.txt" "Error: Ambiguous path. Maze has more than 2 openings."
rm -f maze.txt

(cat << EOF
###############
   # # #      #
# ### # ##### #
# # # # #     #
# # # # # # ###
#         #   #
# ### #########
#   # #        
# # # # # # # #
###############
EOF
) > maze.txt
run_test_args "maze.txt" "Solution exists: NO"
rm -f maze.txt

(cat << EOF
###############
   # # #      #
# ### # ##### #
# # # # #     #
# # # # # # ###
#         #   #
# ### ####### #
#   # #        
# # # # # # # #
###############
EOF
) > maze.txt
run_test_args "maze.txt" "Solution exists: YES"$'\n'"Total moves:     25"$'\n'$'\n'"###############"$'\n'".. # # #      #"$'\n'"#.### # ##### #"$'\n'"#.# # # #...  #"$'\n'"#.# # # #.#.###"$'\n'"#.........#...#"$'\n'"# ### #######.#"$'\n'"#   # #      .."$'\n'"# # # # # # # #"$'\n'"###############"
rm -f maze.txt

(cat << EOF
################# ##
# #     #   #      #
# # ### # ### # ####
#   #       # #    #
### ### ### # # ####
    #   #   # #    #
# ### ####### # # ##
# #           # #  #
####################
EOF
) > maze.txt
run_test_args "maze.txt" "Solution exists: YES"$'\n'"Total moves:     39"$'\n'$'\n'"#################.##"$'\n'"# #.....#   #..... #"$'\n'"# #.###.# ###.# ####"$'\n'"#  .#  .    #.#    #"$'\n'"###.###.### #.# ####"$'\n'"....#...#   #.#    #"$'\n'"# ###.#######.# # ##"$'\n'"# #  .........# #  #"$'\n'"####################"
rm -f maze.txt

(cat << EOF
################# ######################
#     #     #   #           #   #      #
### ##### ### ####### ### ##### ### ####
  #   #           #     #       # #    #
# ### ### ### ### # ####### ### # # # ##
#           #   # #     #   #   #   #  #
# ####### # ### # ### # ### ### # ######
#     #   # #   #     # #   #          #
# # # # # # # # # # # # # # # # # # #  #
########################################
EOF
) > maze.txt
run_test_args "maze.txt" "Solution exists: YES"$'\n'"Total moves:     45"$'\n'$'\n'"#################.######################"$'\n'"#     #     #   #.....      #   #      #"$'\n'"### ##### ### #######.### ##### ### ####"$'\n'"..#   #  .........#...  #       # #    #"$'\n'"#.### ###.### ###.#.####### ### # # # ##"$'\n'"#.........  #   #.#...  #   #   #   #  #"$'\n'"# ####### # ### #.###.# ### ### # ######"$'\n'"#     #   # #   #.....# #   #          #"$'\n'"# # # # # # # # # # # # # # # # # # #  #"$'\n'"########################################"
rm -f maze.txt

(cat << EOF
########################################
#     #     # #     #   # #   #     #  #
# # # ##### # # # ### # # # ####### # ##
  # # #     # # # # # #   #   #   # #  #
# ### ### # # # # # ### ##### # # # # ##
# #   #   # # # #   # # #       #   #  #
### ### ##### # ### # # # # ####### # ##
#   # #         #   #     #   #        #
### # ####### ####### ######### ########
#   # # # #   # # # #     #   # #      #
### # # # # # # # # # ### # # # ##### ##
#     #     #       #   # # #   #   #  #
### ### # ##### ### ##### # ##### ### ##
#       #   # # # # # #   #   #     #  #
# ##### # # # # # # # # ### # # # ### ##
#     # # #   #   #       # #   #      #
# ### # # ######### ##### ##### ##### ##
#   # # #         # #     #     #      #
# # # # # # # # # # # # # # # # # # #  #
################################# ######
EOF
) > maze.txt
run_test_args "maze.txt" "Solution exists: YES"$'\n'"Total moves:     130"$'\n'$'\n'"########################################"$'\n'"#.....#     # #     #   # #   #     #  #"$'\n'"#.# #.##### # # # ### # # # ####### # ##"$'\n'"..# #.#     # # # # # #   #   #...# #  #"$'\n'"# ###.### # # # # # ### ##### #.#.# # ##"$'\n'"# #...#   # # # #   # # #.......#...#  #"$'\n'"###.### ##### # ### # # #.# #######.# ##"$'\n'"#  .# #         #   #.....#   #.....   #"$'\n'"###.# ####### #######.#########.########"$'\n'"#  .# # # #...# # # #.....#...#.#      #"$'\n'"###.# # # #.#.# # # # ###.#.#.#.##### ##"$'\n'"#  .  #.....#.......#   #.#.#...#   #  #"$'\n'"###.###.# ##### ###.#####.#.##### ### ##"$'\n'"#  .....#   # # # #.# #...#...#...  #  #"$'\n'"# ##### # # # # # #.# #.### #.#.#.### ##"$'\n'"#     # # #   #   #.....  # #...#..... #"$'\n'"# ### # # ######### ##### ##### #####.##"$'\n'"#   # # #         # #     #     #..... #"$'\n'"# # # # # # # # # # # # # # # # #.# #  #"$'\n'"#################################.######"
rm -f maze.txt

(cat << EOF
############################################################
#   # #     # #   # #     #   # #   # #   #   # #   # #    #
# # # ### ### # # # # # ##### # # # # # ##### # # # # # # ##
# # # #       # # #   #   # # # # # #     #     # #     #  #
### # # ##### # # # ##### # # # # ### # ### ### # ### # # ##
#   #       # # # #   #   #   # #   # #       #   #   # #  #
### # ### # # # # # # # # ### # ### ####### ################
#   # #   # #   # # # # # #   # #   # #               # #  #
# ### # ######### ### ####### # ### # # # ### # # ### # # ##
# #   # #       # # #     #   # #   #   # #   # # #     #  #
# # # # # # ### # # # # ### ### # # ####### ####### ### # ##
#   # #   #   # # # # #   #     # # # # #   # # #     # #  #
### ##### ######### # ##### ### ### # # ### # # # ##### # ##
#   #             #         # # #   #           #     #    #
############# ######### ### # # ### ### ############### ####
#     #   # #     # #   # #   #     #   # # #   #       #  #
# ### ### # # ### # # # # # ### ### # # # # ### # # ### # ##
# #       #   #   #   #   #   # # #   #     #   # #   # #  #
# # ### ##### # # # ### ### ### # # ### ### ### ### ##### ##
# #   #       # # # # # # #   # #   #     #     #   #      #
# ### # ### ### ### # # # ### # ### ##### ##### # ### # # ##
# #   #   #   #   # #     #   # #   #       #   #     # #  #
# # ####### ##### ### ####### # ### ########### ### ########
# #       #   #           #   # #   #           #           
####### ####################################################
EOF
) > bigmaze.txt
run_test_args "bigmaze.txt" "Solution exists: YES"$'\n'"Total moves:     146"$'\n'$'\n'"############################################################"$'\n'"#   # #     # #   # #     #   # #   # #   #   # #   # #    #"$'\n'"# # # ### ### # # # # # ##### # # # # # ##### # # # # # # ##"$'\n'"# # # #       # # #   #   # # # # # #     #     # #     #  #"$'\n'"### # # ##### # # # ##### # # # # ### # ### ### # ### # # ##"$'\n'"#   #       # # # #   #   #   # #   # #       #   #   # #  #"$'\n'"### # ### # # # # # # # # ### # ### ####### ################"$'\n'"#   # #   # #   # # # # # #   # #   # #      .........# #  #"$'\n'"# ### # ######### ### ####### # ### # # # ###.# # ###.# # ##"$'\n'"# #   # #       # # #     #   # #   #   # #...# # #  ...#  #"$'\n'"# # # # # # ### # # # # ### ### # # #######.####### ###.# ##"$'\n'"#   # #   #   # # # # #   #.....# # # # #  .# # #     #.#  #"$'\n'"### ##### ######### # #####.###.### # # ###.# # # #####.# ##"$'\n'"#   #             #    .....# #.#   #  .....    #     #.   #"$'\n'"############# #########.### # #.### ###.###############.####"$'\n'"#     #   # #.....# #  .# #   #.....#...# # #   #  .....#  #"$'\n'"# ### ### # #.###.# # #.# # ### ###.#.# # # ### # #.### # ##"$'\n'"# #.....  #  .#...#   #.  #   # # #...#     #   # #.  # #  #"$'\n'"# #.###.#####.#.# # ###.### ### # # ### ### ### ###.##### ##"$'\n'"# #...#.......#.# # # #.# #   # #   #     #     #...#      #"$'\n'"# ###.# ### ###.### # #.# ### # ### ##### ##### #.### # # ##"$'\n'"# #...#   #   #...# #...  #   # #   #       #   #...  # #  #"$'\n'"# #.####### #####.###.####### # ### ########### ###.########"$'\n'"# #.....  #   #  .....    #   # #   #           #  ........."$'\n'"#######.####################################################"
rm -f bigmaze.txt

echo -e "\nTotal tests run: $total"
echo -e "Number correct : $num_right"
echo -n "Percent correct: "
echo "scale=2; 100 * $num_right / $total" | bc

if [ "$language" = "java" ]; then
    echo -e -n "\nRemoving class files..."
    rm -f *.class
    echo "done"
elif [ $language = "c" ]; then
    echo -e -n "\nCleaning project..."
    make clean > /dev/null 2>&1
    echo "done"
fi
