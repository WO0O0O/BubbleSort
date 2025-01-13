# ARM Assembly Bubble Sort Implementation

This project contains an implementation of the Bubble Sort algorithm in ARM assembly language. The implementation demonstrates fundamental ARM assembly concepts including register management, memory access, and function calls.

## Algorithm Overview

Bubble Sort is a simple sorting algorithm that repeatedly steps through a list, compares adjacent elements, and swaps them if they are in the wrong order. The pass through the list is repeated until no more swaps are needed.

### Implementation Details

The main file `bubble.s` contains:

1. **Main Components**:
   - `BubbleSort`: Main sorting function
   - `swap`: Helper function to swap array elements
   - `print_array`: Utility function to display array contents

2. **Register Usage**:
   - R0: Array base address
   - R1: Array length (n)
   - R2: Outer loop counter (i)
   - R3: Inner loop counter (j)
   - R4: Inner loop limit (n-i-1)
   - R5,R6: Temporary storage for comparison
   - R7: Original length (preserved for printing)
   - R13: Stack pointer
   - R14: Link register

3. **Key Features**:
   - Word-aligned memory access (LSL #2)
   - Proper register preservation
   - Stack management
   - Debug output after each pass

## Testing

The file `bubbleTEST.s` contains a test version of the implementation with intentionally introduced bugs for debugging practice.

## Memory Requirements

- Stack pointer initialized to 0x10000
- Array elements stored as 32-bit words
- Proper alignment maintained for word access

## Usage

To use the bubble sort:
1. Initialize array in memory
2. Load array address into R0
3. Set array length in R1
4. Call BubbleSort function

Example:
```assembly
        ADRL    R0,array    ; Load array address
        MOV     R1,#10      ; Set length
        BL      BubbleSort  ; Call sort function
```
