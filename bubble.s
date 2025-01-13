        B       test_bubble            ; Branch to main test routine, skipping data section

; Test array with 10 elements
; IMPORTANT: DEFW defines 32-bit words, so we use LSL #2 (multiply by 4) for addressing
; Each number takes 4 bytes in memory
tbs_array       DEFW    10, 25, 13, 44, 9, 15, 6, 27, 36, 42

        ALIGN                       ; Ensure word alignment for data access

test_bubble
        MOV     R13,#0x10000       ; Initialise stack pointer - CRITICAL for function calls, 

        ; Sort the array
        ; IMPORTANT: ADRL is used for loading address of data that's further than 256 bytes
        ADRL    R0,tbs_array       ; R0 = base address of array (first parameter)
        MOV     R1,#10             ; R1 = array length (second parameter)
        BL      BubbleSort         ; Call BubbleSort function

        SWI     2                  ; Exit program

; Print array helper function
; Parameters:
; R0 - array address (preserved in R4)
; R1 - array length
; DEBUG TIP: If numbers look wrong, check LSL #2 is used for array access
print_array
        STMFD   R13!,{R2-R4,R14}   ; Save registers we'll modify (IMPORTANT: include LR!)
        MOV     R2,#0              ; R2 = loop counter (i)
        MOV     R4,R0              ; R4 = save array address (R0 needed for printing)
print_loop
        CMP     R2,R1              ; Check if we've printed all elements
        BGE     print_done         ; If i >= length, we're done
        LDR     R0,[R4,R2,LSL #2]  ; Load array[i]. LSL #2 multiplies i by 4 for word access
        SWI     4                  ; Print number using SWI 4
        MOV     R0,#44             ; Print comma (ASCII 44)
        SWI     0                  ; SWI 0 prints single character
        MOV     R0,#32             ; Print space (ASCII 32)
        SWI     0
        ADD     R2,R2,#1           ; i++
        B       print_loop
print_done
        MOV     R0,#10             ; Print newline (ASCII 10)
        SWI     0
        LDMFD   R13!,{R2-R4,PC}    ; Restore registers and return (PC = saved LR)

; Swap function - modular design like C code
; Parameters:
; R0 - array address
; R1 - index i
; R2 - index j
; DEBUG TIP: If values aren't swapping, check registers are preserved correctly

swap
        STMFD   R13!,{R3-R4,R14}   ; Save registers we'll modify
        LDR     R3,[R0,R1,LSL #2]  ; R3 = temp = arr[i]
        LDR     R4,[R0,R2,LSL #2]  ; R4 = arr[j]
        STR     R4,[R0,R1,LSL #2]  ; arr[i] = arr[j]
        STR     R3,[R0,R2,LSL #2]  ; arr[j] = temp
        LDMFD   R13!,{R3-R4,PC}    ; Restore registers and return

; BubbleSort implementation
; Parameters:
; R0 - array address
; R1 - array length
; DEBUG TIP: Watch R2 (i) and R3 (j) to track loop progress
BubbleSort
        STMFD   R13!,{R2-R7,R14}   ; Save registers we'll modify
        MOV     R7,R1              ; R7 = original length (needed for printing)
        SUB     R1,R1,#1           ; R1 = n-1 (outer loop limit)
        
        MOV     R2,#0              ; R2 = i = 0 (outer loop counter)
outer_loop
        CMP     R2,R1              ; Compare i with n-1
        BGE     done               ; If i >= n-1, we're done
        
        ; Print pass number
        ; DEBUG TIP: Pass numbers help track progress
        STMFD   R13!,{R0-R3}       ; Save registers before printing
        MOV     R0,#80             ; 'P'
        SWI     0
        MOV     R0,#97             ; 'a'
        SWI     0
        MOV     R0,#115            ; 's'
        SWI     0
        MOV     R0,#115            ; 's'
        SWI     0
        MOV     R0,#32             ; Space
        SWI     0
        ADD     R0,R2,#1           ; Pass number = i+1 (make it 1-based)
        SWI     4
        MOV     R0,#10             ; Newline
        SWI     0
        LDMFD   R13!,{R0-R3}       ; Restore registers after printing
        
        MOV     R3,#0              ; R3 = j = 0 (inner loop counter)
        SUB     R4,R1,R2           ; R4 = n-i-1 (inner loop limit)
inner_loop
        CMP     R3,R4              ; Compare j with n-i-1
        BGE     next_pass          ; If j >= n-i-1, this pass is done
        
        ; Print array state after each comparison
        ; DEBUG TIP: Watch array state to track sorting progress
        STMFD   R13!,{R0-R4}       ; Save registers before printing
        MOV     R1,R7              ; Use original length for printing
        BL      print_array
        LDMFD   R13!,{R0-R4}       ; Restore registers after printing
        
        ; Load and compare adjacent elements
        ; DEBUG TIP: Check R5 and R6 values to verify comparison
        LDR     R5,[R0,R3,LSL #2]  ; R5 = array[j]
        ADD     R6,R3,#1           ; R6 = j+1
        LDR     R6,[R0,R6,LSL #2]  ; R6 = array[j+1]
        CMP     R5,R6              ; Compare array[j] with array[j+1]
        BLE     no_swap            ; If array[j] <= array[j+1], no swap needed
        
        ; Call swap function if array[j] > array[j+1]
        STMFD   R13!,{R0-R4}       ; Save registers before swap
        MOV     R1,R3              ; First index = j
        ADD     R2,R3,#1           ; Second index = j+1
        BL      swap
        LDMFD   R13!,{R0-R4}       ; Restore registers after swap
        
no_swap
        ADD     R3,R3,#1           ; j++
        B       inner_loop
        
next_pass
        ADD     R2,R2,#1           ; i++
        B       outer_loop
        
done    
        LDMFD   R13!,{R2-R7,PC}    ; Restore registers and return

; KEY DEBUGGING TIPS:
; 1. Always check LSL #2 is used for array access (32-bit words)
; 2. Watch register preservation around function calls
; 3. Monitor R2 (i) and R3 (j) for loop control
; 4. Use pass numbers and array printing to track progress
; 5. Verify R5 and R6 values before comparison
; 6. Check stack operations (STMFD/LDMFD) are balanced
