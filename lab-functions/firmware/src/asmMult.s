/*** asmMult.s   ***/
    
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Ness Dahan"

.align   /* realign so that next mem allocations are on word boundaries */
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

.global a_Multiplicand,b_Multiplier,a_Sign,b_Sign,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0 
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0 
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

.global asmUnpack, asmAbs, asmMult, asmFixSign, asmMain
.type asmUnpack,%function
.type asmAbs,%function
.type asmMult,%function
.type asmFixSign,%function
.type asmMain,%function

/* function: asmUnpack
 *    inputs:   r0: contains the packed value. 
 *                  MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *              r1: address where to store unpacked, 
 *                  sign-extended 32 bit a value
 *              r2: address where to store unpacked, 
 *                  sign-extended 32 bit b value
 *    outputs:  r0: No return value
 *              memory: 
 *                  1) store unpacked A value in location
 *                     specified by r1
 *                  2) store unpacked B value in location
 *                     specified by r2
 */
asmUnpack:   
    
    /*** REMEMBER: You MUST use the ARM calling convention as described in the lectures! ***/

    /*** STUDENTS: Place your asmUnpack code BELOW this line!!! **************/

    push {r4-r11,LR} /* save r4-r11 and LR on the stack (calling convention) */
    ASR r4, r0, 16 /* r4 = top 16 bits (a), ASR keeps the sign */
    LSL r5, r0, 16 /* r5 = shift b up into the top 16 bits */
    ASR r5, r5, 16 /* shift it back down with ASR so b is sign-extended */
    STR r4, [r1] /* store a at the address in r1 */
    STR r5, [r2] /* store b at the address in r2 */
    pop {r4-r11,LR} /* restore r4-r11 and LR */
    mov pc, lr /* return to caller */

    /*** STUDENTS: Place your asmUnpack code ABOVE this line!!! **************/


    /***************  END ---- asmUnpack  ************/

 
/* function: asmAbs
 *    inputs:   r0: contains signed value
 *              r1: address where to store absolute value
 *              r2: address where to store sign bit 0 = "+", 1 = "-")
 *    outputs:  r0: Absolute value of r0 input. Same value as stored to location given in r1
 *              memory: store absolute value in location given by r1
 *                      store sign bit in location given by r2
 */    
asmAbs:  

    /*** REMEMBER: You MUST use the ARM calling convention as described in the lectures! ***/

    /*** STUDENTS: Place your asmAbs code BELOW this line!!! **************/

    push {r4-r11,LR} /* save r4-r11 and LR */
    LSR r4, r0, 31 /* r4 = bit 31 of the input, 1 if negative, 0 if positive */
    MOV r5, r0 /* r5 = copy of the input, already the abs value if positive */
    CMP r0, 0 /* check if the input is negative */
    BGE abs_store /* if input >= 0 skip the negate */
    RSB r5, r0, 0 /* negative, so r5 = 0 - r0 to get the abs value */
abs_store: /* both paths end up here */
    STR r5, [r1] /* store abs value at the address in r1 */
    STR r4, [r2] /* store sign bit at the address in r2 */
    MOV r0, r5 /* return the abs value in r0 too */
    pop {r4-r11,LR} /* restore r4-r11 and LR */
    mov pc, lr /* return to caller */

    /*** STUDENTS: Place your asmAbs code ABOVE this line!!! **************/


    /***************  END ---- asmAbs  ************/

 
/* function: asmMult
 *    inputs:   r0: contains abs value of multiplicand (a)
 *              r1: contains abs value of multiplier (b)
 *    outputs:  r0: initial product: r0 * r1
 */ 
asmMult:   

    /*** REMEMBER: You MUST use the ARM calling convention as described in the lectures! ***/

    /*** STUDENTS: Place your asmMult code BELOW this line!!! **************/

    push {r4-r11,LR} /* save r4-r11 and LR */
    MOV r4, 0 /* r4 = running product, starts at 0 */
mult_loop: /* top of the shift-and-add loop */
    LSRS r1, r1, 1 /* shift multiplier right 1, the bit that falls out goes into the C flag */
    BCC mult_no_add /* if that bit was 0 (C clear) don't add */
    ADD r4, r4, r0 /* bit was 1, add the shifted multiplicand to the product */
mult_no_add: /* skip-the-add path lands here */
    LSL r0, r0, 1 /* shift multiplicand left 1 (times 2) for the next bit */
    CMP r1, 0 /* any 1 bits left in the multiplier? */
    BNE mult_loop /* yes, keep looping */
    MOV r0, r4 /* put the product in r0 to return it */
    pop {r4-r11,LR} /* restore r4-r11 and LR */
    mov pc, lr /* return to caller */

    /*** STUDENTS: Place your asmMult code ABOVE this line!!! **************/

   
    /***************  END ---- asmMult  ************/


    
/* function: asmFixSign
 *    inputs:   r0: initial product from previous step: 
 *              (abs value of A) * (abs value of B)
 *              r1: sign bit of originally unpacked value
 *                  of A
 *              r2: sign bit of originally unpacked value
 *                  of B
 *    outputs:  r0: final product:
 *                  sign-corrected version of initial product
 */ 
asmFixSign:   
    
    /*** REMEMBER: You MUST use the ARM calling convention as described in the lectures! ***/

    /*** STUDENTS: Place your asmFixSign code BELOW this line!!! **************/

    push {r4-r11,LR} /* save r4-r11 and LR */
    EOR r4, r1, r2 /* r4 = a sign XOR b sign, 0 means same signs */
    CMP r4, 0 /* check if the signs matched */
    BEQ fix_done /* same signs, product stays positive */
    RSB r0, r0, 0 /* signs were different, so make the product negative (0 - r0) */
fix_done: /* done fixing the sign */
    pop {r4-r11,LR} /* restore r4-r11 and LR */
    mov pc, lr /* return to caller with the final product in r0 */

    /*** STUDENTS: Place your asmFixSign code ABOVE this line!!! **************/


    /***************  END ---- asmFixSign  ************/



    
/* function: asmMain
 *    inputs:   r0: contains packed value to be multiplied
 *                  using shift-and-add algorithm
 *           where: MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *    outputs:  r0: final product: sign-corrected product
 *                  of the two unpacked A and B input values
 *    NOTE TO STUDENTS: 
 *           To implement asmMain, follow the steps outlined
 *           in the comments in the body of the function
 *           definition below.
 */  
asmMain:   
    
    /*** REMEMBER: You MUST use the ARM calling convention as described in the lectures! ***/

    /*** STUDENTS: Place your asmMain code BELOW this line!!! **************/
    
    push {r4-r11,LR} /* save r4-r11 and LR before calling other functions (BL changes LR) */

    /* Step 1:
     * call asmUnpack. Have it store the output values in a_Multiplicand
     * and b_Multiplier.
     */
    LDR r1, =a_Multiplicand /* r1 = address to store a, r0 still has the packed input */
    LDR r2, =b_Multiplier /* r2 = address to store b */
    BL asmUnpack /* call asmUnpack */

     /* Step 2a:
      * call asmAbs for the multiplicand (a). Have it store the absolute value
      * in a_Abs, and the sign in a_Sign.
      */
    LDR r0, =a_Multiplicand /* r0 = address of a_Multiplicand */
    LDR r0, [r0] /* r0 = the value of a */
    LDR r1, =a_Abs /* r1 = address for a's abs value */
    LDR r2, =a_Sign /* r2 = address for a's sign bit */
    BL asmAbs /* call asmAbs for a */

     /* Step 2b:
      * call asmAbs for the multiplier (b). Have it store the absolute value
      * in b_Abs, and the sign in b_Sign.
      */
    LDR r0, =b_Multiplier /* r0 = address of b_Multiplier */
    LDR r0, [r0] /* r0 = the value of b */
    LDR r1, =b_Abs /* r1 = address for b's abs value */
    LDR r2, =b_Sign /* r2 = address for b's sign bit */
    BL asmAbs /* call asmAbs for b */

    /* Step 3:
     * call asmMult. Pass a_Abs as the multiplicand, 
     * and b_Abs as the multiplier.
     * asmMult returns the initial (positive) product in r0.
     * In this function (asmMain), store the output value  
     * returned asmMult in r0 to mem location init_Product.
     */
    LDR r0, =a_Abs /* r0 = address of a_Abs */
    LDR r0, [r0] /* r0 = |a|, the multiplicand */
    LDR r1, =b_Abs /* r1 = address of b_Abs */
    LDR r1, [r1] /* r1 = |b|, the multiplier */
    BL asmMult /* call asmMult, product comes back in r0 */
    LDR r1, =init_Product /* r1 = address of init_Product */
    STR r0, [r1] /* save the initial product */

    /* Step 4:
     * call asmFixSign. Pass in the initial product, and the
     * sign bits for the original a and b inputs. 
     * asmFixSign returns the final product with the correct
     * sign. Store the value returned in r0 to mem location 
     * final_Product.
     */
    LDR r1, =a_Sign /* r1 = address of a_Sign */
    LDR r1, [r1] /* r1 = a's sign bit */
    LDR r2, =b_Sign /* r2 = address of b_Sign */
    LDR r2, [r2] /* r2 = b's sign bit */
    BL asmFixSign /* call asmFixSign, r0 already has the initial product */
    LDR r1, =final_Product /* r1 = address of final_Product */
    STR r0, [r1] /* save the final product, r0 keeps it for the return */

     /* Step 5:
      * END! Return to caller. Make sure of the following:
      * 1) Stack has been correctly managed.
      * 2) the final answer is stored in r0, so that the C call 
      *    can access it.
      */
    pop {r4-r11,LR} /* restore r4-r11 and LR */
    mov pc, lr /* return to the C code with the final product in r0 */

    
    /*** STUDENTS: Place your asmMain code ABOVE this line!!! **************/


    /***************  END ---- asmMain  ************/

 
    
    
.end   /* the assembler will ignore anything after this line. */
