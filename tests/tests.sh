#! /bin/bash
# Released under GPL licence v2 or upper
#
# When executed ($ ./tests.sh), no errors should occur in the
# two first sections.  The third one should result in only error messages,
# each one different. Segfault or default error messages must not appear.
#
# The following lines are the expected results:
#         Result between right limits
# 1d2: OK
# 1d2+1: OK
# 1d2*2: OK
# 1d2-1: OK
# 2d2h1: OK
# 3d2h2: OK
# 3d2s1h1: OK

#         Use argv
# 1
# 3
# Roll #1:
#   Dice: (1) = 1
#   = 1
# Roll #1:
#   Dice: (1) = 1
#   = 1
# Roll #1:
#   Dice: (2) = 2
#   = 2
# 2
# 1
# 76
# 6
# 5
# 8

#         Use stdin
# 1d2
# 1
# 1d3
# 3
# 2d2+2
# 5
# 3d6h1
# 9
# 4d6s1h1
# 9
# 1d2
# Roll #1:
#   Dice: (1) = 1
#   = 1
# 1d3
# Roll #1:
#   Dice: (3) = 3
#   = 3
# 2d2+2
# Roll #1:
#   Dice: (2 2) = 4
#   + 2  = 6
# 3d6h1
# Roll #1:
#   Dice: (2 3 1) = 6
#   Drop highest 1: (-3) = 3
#   = 3
# 4d6s1h1
# Roll #1:
#   Dice: (1 3 6 3) = 13
#   Drop lowest 1: (-1) = 12
#   Drop highest 1: (-6) = 6
#   = 6

#         Error messages handle numbers that are too large
# rolldice: Requested number of dice faces is too large
# rolldice: Requested number of dropped dice is too large
# rolldice: Requested number of dropped dice is too large
# rolldice: Requested number of rolled dice is too large
# rolldice: Requested multiplier is too large
# rolldice: Requested add modifier is too large
# rolldice: Requested minus modifier is too large


function check_result {
    OUTPUT=`../rolldice $1`
    EXIT_VAL=$?
    TEST_SUCCESS=true
    
    if [[ $EXIT_VAL != 0 ]]
        then
            echo ${1}": ERROR (return value)"
            TEST_SUCCESS=false
    fi

    if echo ${OUTPUT} | grep -q -v $2
        then
            echo ${1}": ERROR ("${OUTPUT}")"
            TEST_SUCCESS=false
    fi

    if $TEST_SUCCESS;
        then
            echo ${1}": OK"
    fi
}

function check_error {
    OUTPUT=`../rolldice $1`
    EXIT_VAL=$?

    # 65 == EX_DATAERR /* data format error */
    if [[ $EXIT_VAL != 65 ]] 
        then
            echo ${1}": ERROR ("$EXIT_VAL" instead of 65)"
    fi
    
}

echo -e "\tResult between right limits"
check_result "1d2" "^[12]"
check_result "1d2+1" "^[23]"
check_result "1d2*2" "^[24]"
check_result "1d2-1" "^[01]"
check_result "2d2h1" "^[12]"  # Should return the lowest of two dice
check_result "3d2h2" "^[12]"  # Should return the lowest of three dice
check_result "3d2s1h1" "^[12]"  # Should drop lowest and highest, sum remaining

echo ""
echo -e "\tUse argv"
../rolldice 1d2
../rolldice 1d2+1
../rolldice -s 1d2
../rolldice -s -u 1d2
../rolldice -s -r 1d2
../rolldice 1d2 1d3
../rolldice 1d%
../rolldice 1d%+1
../rolldice 3d6h1  # Test dropping highest
../rolldice 4d6s1h1  # Test dropping both lowest and highest

echo ""
echo -e "\tUse stdin"
cat rollfile | ../rolldice
cat rollfile | ../rolldice -s 

echo ""
echo -e "\tError messages handle numbers that are too large"
check_error "1d123456789"
check_error "2d3s123456789"
check_error "2d3h123456789"  # Test error for too many highest dice to drop
check_error "123456789x2d2"
check_error "2d2*123456789"
check_error "2d2+123456789"
check_error "2d2-123456789"

