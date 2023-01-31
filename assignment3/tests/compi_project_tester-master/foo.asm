%define T_void 				0
%define T_nil 				1
%define T_char 				2
%define T_string 			3
%define T_symbol 			4
%define T_closure 			5
%define T_boolean 			8
%define T_boolean_false 		(T_boolean | 1)
%define T_boolean_true 			(T_boolean | 2)
%define T_number 			16
%define T_rational 			(T_number | 1)
%define T_real 				(T_number | 2)
%define T_collection 			32
%define T_pair 				(T_collection | 1)
%define T_vector 			(T_collection | 2)

%define SOB_CHAR_VALUE(reg) 		byte [reg + 1]
%define SOB_PAIR_CAR(reg)		qword [reg + 1]
%define SOB_PAIR_CDR(reg)		qword [reg + 1 + 8]
%define SOB_STRING_LENGTH(reg)		qword [reg + 1]
%define SOB_VECTOR_LENGTH(reg)		qword [reg + 1]
%define SOB_CLOSURE_ENV(reg)		qword [reg + 1]
%define SOB_CLOSURE_CODE(reg)		qword [reg + 1 + 8]

%define OLD_RDP 			qword [rbp]
%define RET_ADDR 			qword [rbp + 8 * 1]
%define ENV 				qword [rbp + 8 * 2]
%define COUNT 				qword [rbp + 8 * 3]
%define PARAM(n) 			qword [rbp + 8 * (4 + n)]
%define AND_KILL_FRAME(n)		(8 * (2 + n))

%macro ENTER 0
	enter 0, 0
	and rsp, ~15
%endmacro

%macro LEAVE 0
	leave
%endmacro

%macro assert_type 2
        cmp byte [%1], %2
        jne L_error_incorrect_type
%endmacro

%macro assert_type_integer 1
        assert_rational(%1)
        cmp qword [%1 + 1 + 8], 1
        jne L_error_incorrect_type
%endmacro

%define assert_void(reg)		assert_type reg, T_void
%define assert_nil(reg)			assert_type reg, T_nil
%define assert_char(reg)		assert_type reg, T_char
%define assert_string(reg)		assert_type reg, T_string
%define assert_symbol(reg)		assert_type reg, T_symbol
%define assert_closure(reg)		assert_type reg, T_closure
%define assert_boolean(reg)		assert_type reg, T_boolean
%define assert_rational(reg)		assert_type reg, T_rational
%define assert_integer(reg)		assert_type_integer reg
%define assert_real(reg)		assert_type reg, T_real
%define assert_pair(reg)		assert_type reg, T_pair
%define assert_vector(reg)		assert_type reg, T_vector

%define sob_void			(L_constants + 0)
%define sob_nil				(L_constants + 1)
%define sob_boolean_false		(L_constants + 2)
%define sob_boolean_true		(L_constants + 3)
%define sob_char_nul			(L_constants + 4)

%define bytes(n)			(n)
%define kbytes(n) 			(bytes(n) << 10)
%define mbytes(n) 			(kbytes(n) << 10)
%define gbytes(n) 			(mbytes(n) << 10)

section .data
L_constants:
	db T_void
	db T_nil
	db T_boolean_false
	db T_boolean_true
	db T_char, 0x00	; #\x0
	db T_string	; "whatever"
	dq 8
	db 0x77, 0x68, 0x61, 0x74, 0x65, 0x76, 0x65, 0x72
	db T_symbol	; whatever
	dq L_constants + 6
	db T_rational	; 0
	dq 0, 1
	db T_string	; "+"
	dq 1
	db 0x2B
	db T_symbol	; +
	dq L_constants + 49
	db T_string	; "all arguments need ...
	dq 32
	db 0x61, 0x6C, 0x6C, 0x20, 0x61, 0x72, 0x67, 0x75
	db 0x6D, 0x65, 0x6E, 0x74, 0x73, 0x20, 0x6E, 0x65
	db 0x65, 0x64, 0x20, 0x74, 0x6F, 0x20, 0x62, 0x65
	db 0x20, 0x6E, 0x75, 0x6D, 0x62, 0x65, 0x72, 0x73
	db T_string	; "-"
	dq 1
	db 0x2D
	db T_symbol	; -
	dq L_constants + 109
	db T_rational	; 1
	dq 1, 1
	db T_string	; "*"
	dq 1
	db 0x2A
	db T_symbol	; *
	dq L_constants + 145
	db T_string	; "/"
	dq 1
	db 0x2F
	db T_symbol	; /
	dq L_constants + 164
	db T_string	; "generic-comparator"
	dq 18
	db 0x67, 0x65, 0x6E, 0x65, 0x72, 0x69, 0x63, 0x2D
	db 0x63, 0x6F, 0x6D, 0x70, 0x61, 0x72, 0x61, 0x74
	db 0x6F, 0x72
	db T_symbol	; generic-comparator
	dq L_constants + 183
	db T_string	; "all the arguments m...
	dq 33
	db 0x61, 0x6C, 0x6C, 0x20, 0x74, 0x68, 0x65, 0x20
	db 0x61, 0x72, 0x67, 0x75, 0x6D, 0x65, 0x6E, 0x74
	db 0x73, 0x20, 0x6D, 0x75, 0x73, 0x74, 0x20, 0x62
	db 0x65, 0x20, 0x6E, 0x75, 0x6D, 0x62, 0x65, 0x72
	db 0x73
	db T_string	; "make-list"
	dq 9
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x6C, 0x69, 0x73
	db 0x74
	db T_symbol	; make-list
	dq L_constants + 261
	db T_string	; "Usage: (make-list l...
	dq 45
	db 0x55, 0x73, 0x61, 0x67, 0x65, 0x3A, 0x20, 0x28
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x6C, 0x69, 0x73
	db 0x74, 0x20, 0x6C, 0x65, 0x6E, 0x67, 0x74, 0x68
	db 0x20, 0x3F, 0x6F, 0x70, 0x74, 0x69, 0x6F, 0x6E
	db 0x61, 0x6C, 0x2D, 0x69, 0x6E, 0x69, 0x74, 0x2D
	db 0x63, 0x68, 0x61, 0x72, 0x29
	db T_char, 0x41	; #\A
	db T_char, 0x5A	; #\Z
	db T_char, 0x61	; #\a
	db T_char, 0x7A	; #\z
	db T_string	; "make-vector"
	dq 11
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x76, 0x65, 0x63
	db 0x74, 0x6F, 0x72
	db T_symbol	; make-vector
	dq L_constants + 350
	db T_string	; "Usage: (make-vector...
	dq 43
	db 0x55, 0x73, 0x61, 0x67, 0x65, 0x3A, 0x20, 0x28
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x76, 0x65, 0x63
	db 0x74, 0x6F, 0x72, 0x20, 0x73, 0x69, 0x7A, 0x65
	db 0x20, 0x3F, 0x6F, 0x70, 0x74, 0x69, 0x6F, 0x6E
	db 0x61, 0x6C, 0x2D, 0x64, 0x65, 0x66, 0x61, 0x75
	db 0x6C, 0x74, 0x29
	db T_string	; "make-string"
	dq 11
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x73, 0x74, 0x72
	db 0x69, 0x6E, 0x67
	db T_symbol	; make-string
	dq L_constants + 431
	db T_string	; "Usage: (make-string...
	dq 43
	db 0x55, 0x73, 0x61, 0x67, 0x65, 0x3A, 0x20, 0x28
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x73, 0x74, 0x72
	db 0x69, 0x6E, 0x67, 0x20, 0x73, 0x69, 0x7A, 0x65
	db 0x20, 0x3F, 0x6F, 0x70, 0x74, 0x69, 0x6F, 0x6E
	db 0x61, 0x6C, 0x2D, 0x64, 0x65, 0x66, 0x61, 0x75
	db 0x6C, 0x74, 0x29
	db T_rational	; 2
	dq 2, 1
	db T_string	; "odd-2"
	dq 5
	db 0x6F, 0x64, 0x64, 0x2D, 0x32
	db T_symbol	; odd-2
	dq L_constants + 529
	db T_string	; "odd-5"
	dq 5
	db 0x6F, 0x64, 0x64, 0x2D, 0x35
	db T_symbol	; odd-5
	dq L_constants + 552
	db T_string	; "odder-5"
	dq 7
	db 0x6F, 0x64, 0x64, 0x65, 0x72, 0x2D, 0x35
	db T_symbol	; odder-5
	dq L_constants + 575
	db T_rational	; 100
	dq 100, 1

section .bss
free_var_0:	; location of null?
	resq 1
free_var_1:	; location of pair?
	resq 1
free_var_2:	; location of void?
	resq 1
free_var_3:	; location of char?
	resq 1
free_var_4:	; location of string?
	resq 1
free_var_5:	; location of symbol?
	resq 1
free_var_6:	; location of vector?
	resq 1
free_var_7:	; location of procedure?
	resq 1
free_var_8:	; location of real?
	resq 1
free_var_9:	; location of rational?
	resq 1
free_var_10:	; location of boolean?
	resq 1
free_var_11:	; location of number?
	resq 1
free_var_12:	; location of collection?
	resq 1
free_var_13:	; location of cons
	resq 1
free_var_14:	; location of display-sexpr
	resq 1
free_var_15:	; location of write-char
	resq 1
free_var_16:	; location of car
	resq 1
free_var_17:	; location of cdr
	resq 1
free_var_18:	; location of string-length
	resq 1
free_var_19:	; location of vector-length
	resq 1
free_var_20:	; location of real->integer
	resq 1
free_var_21:	; location of exit
	resq 1
free_var_22:	; location of integer->real
	resq 1
free_var_23:	; location of rational->real
	resq 1
free_var_24:	; location of char->integer
	resq 1
free_var_25:	; location of integer->char
	resq 1
free_var_26:	; location of trng
	resq 1
free_var_27:	; location of zero?
	resq 1
free_var_28:	; location of integer?
	resq 1
free_var_29:	; location of __bin-apply
	resq 1
free_var_30:	; location of __bin-add-rr
	resq 1
free_var_31:	; location of __bin-sub-rr
	resq 1
free_var_32:	; location of __bin-mul-rr
	resq 1
free_var_33:	; location of __bin-div-rr
	resq 1
free_var_34:	; location of __bin-add-qq
	resq 1
free_var_35:	; location of __bin-sub-qq
	resq 1
free_var_36:	; location of __bin-mul-qq
	resq 1
free_var_37:	; location of __bin-div-qq
	resq 1
free_var_38:	; location of error
	resq 1
free_var_39:	; location of __bin-less-than-rr
	resq 1
free_var_40:	; location of __bin-less-than-qq
	resq 1
free_var_41:	; location of __bin-equal-rr
	resq 1
free_var_42:	; location of __bin-equal-qq
	resq 1
free_var_43:	; location of quotient
	resq 1
free_var_44:	; location of remainder
	resq 1
free_var_45:	; location of set-car!
	resq 1
free_var_46:	; location of set-cdr!
	resq 1
free_var_47:	; location of string-ref
	resq 1
free_var_48:	; location of vector-ref
	resq 1
free_var_49:	; location of vector-set!
	resq 1
free_var_50:	; location of string-set!
	resq 1
free_var_51:	; location of make-vector
	resq 1
free_var_52:	; location of make-string
	resq 1
free_var_53:	; location of numerator
	resq 1
free_var_54:	; location of denominator
	resq 1
free_var_55:	; location of eq?
	resq 1
free_var_56:	; location of caar
	resq 1
free_var_57:	; location of cadr
	resq 1
free_var_58:	; location of cdar
	resq 1
free_var_59:	; location of cddr
	resq 1
free_var_60:	; location of caaar
	resq 1
free_var_61:	; location of caadr
	resq 1
free_var_62:	; location of cadar
	resq 1
free_var_63:	; location of caddr
	resq 1
free_var_64:	; location of cdaar
	resq 1
free_var_65:	; location of cdadr
	resq 1
free_var_66:	; location of cddar
	resq 1
free_var_67:	; location of cdddr
	resq 1
free_var_68:	; location of caaaar
	resq 1
free_var_69:	; location of caaadr
	resq 1
free_var_70:	; location of caadar
	resq 1
free_var_71:	; location of caaddr
	resq 1
free_var_72:	; location of cadaar
	resq 1
free_var_73:	; location of cadadr
	resq 1
free_var_74:	; location of caddar
	resq 1
free_var_75:	; location of cadddr
	resq 1
free_var_76:	; location of cdaaar
	resq 1
free_var_77:	; location of cdaadr
	resq 1
free_var_78:	; location of cdadar
	resq 1
free_var_79:	; location of cdaddr
	resq 1
free_var_80:	; location of cddaar
	resq 1
free_var_81:	; location of cddadr
	resq 1
free_var_82:	; location of cdddar
	resq 1
free_var_83:	; location of cddddr
	resq 1
free_var_84:	; location of list?
	resq 1
free_var_85:	; location of list
	resq 1
free_var_86:	; location of not
	resq 1
free_var_87:	; location of fraction?
	resq 1
free_var_88:	; location of list*
	resq 1
free_var_89:	; location of apply
	resq 1
free_var_90:	; location of ormap
	resq 1
free_var_91:	; location of map
	resq 1
free_var_92:	; location of andmap
	resq 1
free_var_93:	; location of reverse
	resq 1
free_var_94:	; location of append
	resq 1
free_var_95:	; location of fold-left
	resq 1
free_var_96:	; location of fold-right
	resq 1
free_var_97:	; location of +
	resq 1
free_var_98:	; location of -
	resq 1
free_var_99:	; location of *
	resq 1
free_var_100:	; location of /
	resq 1
free_var_101:	; location of fact
	resq 1
free_var_102:	; location of <
	resq 1
free_var_103:	; location of <=
	resq 1
free_var_104:	; location of >
	resq 1
free_var_105:	; location of >=
	resq 1
free_var_106:	; location of =
	resq 1
free_var_107:	; location of make-list
	resq 1
free_var_108:	; location of char<?
	resq 1
free_var_109:	; location of char<=?
	resq 1
free_var_110:	; location of char=?
	resq 1
free_var_111:	; location of char>?
	resq 1
free_var_112:	; location of char>=?
	resq 1
free_var_113:	; location of char-downcase
	resq 1
free_var_114:	; location of char-upcase
	resq 1
free_var_115:	; location of char-ci<?
	resq 1
free_var_116:	; location of char-ci<=?
	resq 1
free_var_117:	; location of char-ci=?
	resq 1
free_var_118:	; location of char-ci>?
	resq 1
free_var_119:	; location of char-ci>=?
	resq 1
free_var_120:	; location of string-downcase
	resq 1
free_var_121:	; location of string-upcase
	resq 1
free_var_122:	; location of list->string
	resq 1
free_var_123:	; location of string->list
	resq 1
free_var_124:	; location of string<?
	resq 1
free_var_125:	; location of string<=?
	resq 1
free_var_126:	; location of string=?
	resq 1
free_var_127:	; location of string>=?
	resq 1
free_var_128:	; location of string>?
	resq 1
free_var_129:	; location of string-ci<?
	resq 1
free_var_130:	; location of string-ci<=?
	resq 1
free_var_131:	; location of string-ci=?
	resq 1
free_var_132:	; location of string-ci>=?
	resq 1
free_var_133:	; location of string-ci>?
	resq 1
free_var_134:	; location of length
	resq 1
free_var_135:	; location of list->vector
	resq 1
free_var_136:	; location of vector
	resq 1
free_var_137:	; location of vector->list
	resq 1
free_var_138:	; location of random
	resq 1
free_var_139:	; location of positive?
	resq 1
free_var_140:	; location of negative?
	resq 1
free_var_141:	; location of even?
	resq 1
free_var_142:	; location of odd?
	resq 1
free_var_143:	; location of abs
	resq 1
free_var_144:	; location of equal?
	resq 1
free_var_145:	; location of assoc
	resq 1

extern printf, fprintf, stdout, stderr, fwrite, exit, putchar
global main
section .text
main:
        enter 0, 0
        
	; building closure for null?
	mov rdi, free_var_0
	mov rsi, L_code_ptr_is_null
	call bind_primitive

	; building closure for pair?
	mov rdi, free_var_1
	mov rsi, L_code_ptr_is_pair
	call bind_primitive

	; building closure for void?
	mov rdi, free_var_2
	mov rsi, L_code_ptr_is_void
	call bind_primitive

	; building closure for char?
	mov rdi, free_var_3
	mov rsi, L_code_ptr_is_char
	call bind_primitive

	; building closure for string?
	mov rdi, free_var_4
	mov rsi, L_code_ptr_is_string
	call bind_primitive

	; building closure for symbol?
	mov rdi, free_var_5
	mov rsi, L_code_ptr_is_symbol
	call bind_primitive

	; building closure for vector?
	mov rdi, free_var_6
	mov rsi, L_code_ptr_is_vector
	call bind_primitive

	; building closure for procedure?
	mov rdi, free_var_7
	mov rsi, L_code_ptr_is_closure
	call bind_primitive

	; building closure for real?
	mov rdi, free_var_8
	mov rsi, L_code_ptr_is_real
	call bind_primitive

	; building closure for rational?
	mov rdi, free_var_9
	mov rsi, L_code_ptr_is_rational
	call bind_primitive

	; building closure for boolean?
	mov rdi, free_var_10
	mov rsi, L_code_ptr_is_boolean
	call bind_primitive

	; building closure for number?
	mov rdi, free_var_11
	mov rsi, L_code_ptr_is_number
	call bind_primitive

	; building closure for collection?
	mov rdi, free_var_12
	mov rsi, L_code_ptr_is_collection
	call bind_primitive

	; building closure for cons
	mov rdi, free_var_13
	mov rsi, L_code_ptr_cons
	call bind_primitive

	; building closure for display-sexpr
	mov rdi, free_var_14
	mov rsi, L_code_ptr_display_sexpr
	call bind_primitive

	; building closure for write-char
	mov rdi, free_var_15
	mov rsi, L_code_ptr_write_char
	call bind_primitive

	; building closure for car
	mov rdi, free_var_16
	mov rsi, L_code_ptr_car
	call bind_primitive

	; building closure for cdr
	mov rdi, free_var_17
	mov rsi, L_code_ptr_cdr
	call bind_primitive

	; building closure for string-length
	mov rdi, free_var_18
	mov rsi, L_code_ptr_string_length
	call bind_primitive

	; building closure for vector-length
	mov rdi, free_var_19
	mov rsi, L_code_ptr_vector_length
	call bind_primitive

	; building closure for real->integer
	mov rdi, free_var_20
	mov rsi, L_code_ptr_real_to_integer
	call bind_primitive

	; building closure for exit
	mov rdi, free_var_21
	mov rsi, L_code_ptr_exit
	call bind_primitive

	; building closure for integer->real
	mov rdi, free_var_22
	mov rsi, L_code_ptr_integer_to_real
	call bind_primitive

	; building closure for rational->real
	mov rdi, free_var_23
	mov rsi, L_code_ptr_rational_to_real
	call bind_primitive

	; building closure for char->integer
	mov rdi, free_var_24
	mov rsi, L_code_ptr_char_to_integer
	call bind_primitive

	; building closure for integer->char
	mov rdi, free_var_25
	mov rsi, L_code_ptr_integer_to_char
	call bind_primitive

	; building closure for trng
	mov rdi, free_var_26
	mov rsi, L_code_ptr_trng
	call bind_primitive

	; building closure for zero?
	mov rdi, free_var_27
	mov rsi, L_code_ptr_is_zero
	call bind_primitive

	; building closure for integer?
	mov rdi, free_var_28
	mov rsi, L_code_ptr_is_integer
	call bind_primitive

	; building closure for __bin-apply
	mov rdi, free_var_29
	mov rsi, L_code_ptr_bin_apply
	call bind_primitive

	; building closure for __bin-add-rr
	mov rdi, free_var_30
	mov rsi, L_code_ptr_raw_bin_add_rr
	call bind_primitive

	; building closure for __bin-sub-rr
	mov rdi, free_var_31
	mov rsi, L_code_ptr_raw_bin_sub_rr
	call bind_primitive

	; building closure for __bin-mul-rr
	mov rdi, free_var_32
	mov rsi, L_code_ptr_raw_bin_mul_rr
	call bind_primitive

	; building closure for __bin-div-rr
	mov rdi, free_var_33
	mov rsi, L_code_ptr_raw_bin_div_rr
	call bind_primitive

	; building closure for __bin-add-qq
	mov rdi, free_var_34
	mov rsi, L_code_ptr_raw_bin_add_qq
	call bind_primitive

	; building closure for __bin-sub-qq
	mov rdi, free_var_35
	mov rsi, L_code_ptr_raw_bin_sub_qq
	call bind_primitive

	; building closure for __bin-mul-qq
	mov rdi, free_var_36
	mov rsi, L_code_ptr_raw_bin_mul_qq
	call bind_primitive

	; building closure for __bin-div-qq
	mov rdi, free_var_37
	mov rsi, L_code_ptr_raw_bin_div_qq
	call bind_primitive

	; building closure for error
	mov rdi, free_var_38
	mov rsi, L_code_ptr_error
	call bind_primitive

	; building closure for __bin-less-than-rr
	mov rdi, free_var_39
	mov rsi, L_code_ptr_raw_less_than_rr
	call bind_primitive

	; building closure for __bin-less-than-qq
	mov rdi, free_var_40
	mov rsi, L_code_ptr_raw_less_than_qq
	call bind_primitive

	; building closure for __bin-equal-rr
	mov rdi, free_var_41
	mov rsi, L_code_ptr_raw_equal_rr
	call bind_primitive

	; building closure for __bin-equal-qq
	mov rdi, free_var_42
	mov rsi, L_code_ptr_raw_equal_qq
	call bind_primitive

	; building closure for quotient
	mov rdi, free_var_43
	mov rsi, L_code_ptr_quotient
	call bind_primitive

	; building closure for remainder
	mov rdi, free_var_44
	mov rsi, L_code_ptr_remainder
	call bind_primitive

	; building closure for set-car!
	mov rdi, free_var_45
	mov rsi, L_code_ptr_set_car
	call bind_primitive

	; building closure for set-cdr!
	mov rdi, free_var_46
	mov rsi, L_code_ptr_set_cdr
	call bind_primitive

	; building closure for string-ref
	mov rdi, free_var_47
	mov rsi, L_code_ptr_string_ref
	call bind_primitive

	; building closure for vector-ref
	mov rdi, free_var_48
	mov rsi, L_code_ptr_vector_ref
	call bind_primitive

	; building closure for vector-set!
	mov rdi, free_var_49
	mov rsi, L_code_ptr_vector_set
	call bind_primitive

	; building closure for string-set!
	mov rdi, free_var_50
	mov rsi, L_code_ptr_string_set
	call bind_primitive

	; building closure for make-vector
	mov rdi, free_var_51
	mov rsi, L_code_ptr_make_vector
	call bind_primitive

	; building closure for make-string
	mov rdi, free_var_52
	mov rsi, L_code_ptr_make_string
	call bind_primitive

	; building closure for numerator
	mov rdi, free_var_53
	mov rsi, L_code_ptr_numerator
	call bind_primitive

	; building closure for denominator
	mov rdi, free_var_54
	mov rsi, L_code_ptr_denominator
	call bind_primitive

	; building closure for eq?
	mov rdi, free_var_55
	mov rsi, L_code_ptr_eq
	call bind_primitive

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3729:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3729
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3729
.L_lambda_simple_env_end_3729:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3729:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3729
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3729
.L_lambda_simple_params_end_3729:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3729
	jmp .L_lambda_simple_end_3729
.L_lambda_simple_code_3729:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3729
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3729:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_16]
.L_applic_TC_3fc5:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fc5:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fc5
.L_tc_recycle_frame_done_3fc5:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3729:	; new closure is in rax
	mov qword [free_var_56], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_372a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_372a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_372a
.L_lambda_simple_env_end_372a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_372a:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_372a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_372a
.L_lambda_simple_params_end_372a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_372a
	jmp .L_lambda_simple_end_372a
.L_lambda_simple_code_372a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_372a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_372a:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_16]
.L_applic_TC_3fc6:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fc6:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fc6
.L_tc_recycle_frame_done_3fc6:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_372a:	; new closure is in rax
	mov qword [free_var_57], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_372b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_372b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_372b
.L_lambda_simple_env_end_372b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_372b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_372b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_372b
.L_lambda_simple_params_end_372b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_372b
	jmp .L_lambda_simple_end_372b
.L_lambda_simple_code_372b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_372b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_372b:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_17]
.L_applic_TC_3fc7:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fc7:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fc7
.L_tc_recycle_frame_done_3fc7:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_372b:	; new closure is in rax
	mov qword [free_var_58], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_372c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_372c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_372c
.L_lambda_simple_env_end_372c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_372c:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_372c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_372c
.L_lambda_simple_params_end_372c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_372c
	jmp .L_lambda_simple_end_372c
.L_lambda_simple_code_372c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_372c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_372c:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_17]
.L_applic_TC_3fc8:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fc8:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fc8
.L_tc_recycle_frame_done_3fc8:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_372c:	; new closure is in rax
	mov qword [free_var_59], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_372d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_372d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_372d
.L_lambda_simple_env_end_372d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_372d:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_372d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_372d
.L_lambda_simple_params_end_372d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_372d
	jmp .L_lambda_simple_end_372d
.L_lambda_simple_code_372d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_372d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_372d:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_16]
.L_applic_TC_3fc9:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fc9:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fc9
.L_tc_recycle_frame_done_3fc9:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_372d:	; new closure is in rax
	mov qword [free_var_60], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_372e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_372e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_372e
.L_lambda_simple_env_end_372e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_372e:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_372e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_372e
.L_lambda_simple_params_end_372e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_372e
	jmp .L_lambda_simple_end_372e
.L_lambda_simple_code_372e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_372e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_372e:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_16]
.L_applic_TC_3fca:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fca:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fca
.L_tc_recycle_frame_done_3fca:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_372e:	; new closure is in rax
	mov qword [free_var_61], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_372f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_372f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_372f
.L_lambda_simple_env_end_372f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_372f:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_372f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_372f
.L_lambda_simple_params_end_372f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_372f
	jmp .L_lambda_simple_end_372f
.L_lambda_simple_code_372f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_372f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_372f:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_16]
.L_applic_TC_3fcb:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fcb:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fcb
.L_tc_recycle_frame_done_3fcb:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_372f:	; new closure is in rax
	mov qword [free_var_62], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3730:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3730
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3730
.L_lambda_simple_env_end_3730:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3730:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3730
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3730
.L_lambda_simple_params_end_3730:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3730
	jmp .L_lambda_simple_end_3730
.L_lambda_simple_code_3730:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3730
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3730:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_16]
.L_applic_TC_3fcc:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fcc:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fcc
.L_tc_recycle_frame_done_3fcc:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3730:	; new closure is in rax
	mov qword [free_var_63], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3731:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3731
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3731
.L_lambda_simple_env_end_3731:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3731:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3731
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3731
.L_lambda_simple_params_end_3731:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3731
	jmp .L_lambda_simple_end_3731
.L_lambda_simple_code_3731:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3731
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3731:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_17]
.L_applic_TC_3fcd:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fcd:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fcd
.L_tc_recycle_frame_done_3fcd:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3731:	; new closure is in rax
	mov qword [free_var_64], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3732:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3732
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3732
.L_lambda_simple_env_end_3732:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3732:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3732
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3732
.L_lambda_simple_params_end_3732:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3732
	jmp .L_lambda_simple_end_3732
.L_lambda_simple_code_3732:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3732
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3732:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_17]
.L_applic_TC_3fce:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fce:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fce
.L_tc_recycle_frame_done_3fce:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3732:	; new closure is in rax
	mov qword [free_var_65], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3733:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3733
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3733
.L_lambda_simple_env_end_3733:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3733:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3733
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3733
.L_lambda_simple_params_end_3733:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3733
	jmp .L_lambda_simple_end_3733
.L_lambda_simple_code_3733:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3733
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3733:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_17]
.L_applic_TC_3fcf:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fcf:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fcf
.L_tc_recycle_frame_done_3fcf:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3733:	; new closure is in rax
	mov qword [free_var_66], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3734:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3734
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3734
.L_lambda_simple_env_end_3734:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3734:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3734
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3734
.L_lambda_simple_params_end_3734:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3734
	jmp .L_lambda_simple_end_3734
.L_lambda_simple_code_3734:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3734
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3734:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_17]
.L_applic_TC_3fd0:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fd0:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fd0
.L_tc_recycle_frame_done_3fd0:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3734:	; new closure is in rax
	mov qword [free_var_67], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3735:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3735
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3735
.L_lambda_simple_env_end_3735:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3735:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3735
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3735
.L_lambda_simple_params_end_3735:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3735
	jmp .L_lambda_simple_end_3735
.L_lambda_simple_code_3735:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3735
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3735:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_56]
.L_applic_TC_3fd1:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fd1:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fd1
.L_tc_recycle_frame_done_3fd1:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3735:	; new closure is in rax
	mov qword [free_var_68], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3736:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3736
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3736
.L_lambda_simple_env_end_3736:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3736:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3736
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3736
.L_lambda_simple_params_end_3736:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3736
	jmp .L_lambda_simple_end_3736
.L_lambda_simple_code_3736:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3736
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3736:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_56]
.L_applic_TC_3fd2:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fd2:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fd2
.L_tc_recycle_frame_done_3fd2:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3736:	; new closure is in rax
	mov qword [free_var_69], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3737:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3737
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3737
.L_lambda_simple_env_end_3737:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3737:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3737
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3737
.L_lambda_simple_params_end_3737:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3737
	jmp .L_lambda_simple_end_3737
.L_lambda_simple_code_3737:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3737
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3737:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_56]
.L_applic_TC_3fd3:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fd3:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fd3
.L_tc_recycle_frame_done_3fd3:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3737:	; new closure is in rax
	mov qword [free_var_70], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3738:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3738
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3738
.L_lambda_simple_env_end_3738:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3738:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3738
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3738
.L_lambda_simple_params_end_3738:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3738
	jmp .L_lambda_simple_end_3738
.L_lambda_simple_code_3738:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3738
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3738:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_56]
.L_applic_TC_3fd4:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fd4:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fd4
.L_tc_recycle_frame_done_3fd4:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3738:	; new closure is in rax
	mov qword [free_var_71], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3739:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3739
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3739
.L_lambda_simple_env_end_3739:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3739:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3739
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3739
.L_lambda_simple_params_end_3739:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3739
	jmp .L_lambda_simple_end_3739
.L_lambda_simple_code_3739:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3739
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3739:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_57]
.L_applic_TC_3fd5:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fd5:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fd5
.L_tc_recycle_frame_done_3fd5:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3739:	; new closure is in rax
	mov qword [free_var_72], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_373a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_373a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_373a
.L_lambda_simple_env_end_373a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_373a:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_373a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_373a
.L_lambda_simple_params_end_373a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_373a
	jmp .L_lambda_simple_end_373a
.L_lambda_simple_code_373a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_373a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_373a:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_57]
.L_applic_TC_3fd6:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fd6:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fd6
.L_tc_recycle_frame_done_3fd6:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_373a:	; new closure is in rax
	mov qword [free_var_73], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_373b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_373b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_373b
.L_lambda_simple_env_end_373b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_373b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_373b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_373b
.L_lambda_simple_params_end_373b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_373b
	jmp .L_lambda_simple_end_373b
.L_lambda_simple_code_373b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_373b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_373b:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_57]
.L_applic_TC_3fd7:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fd7:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fd7
.L_tc_recycle_frame_done_3fd7:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_373b:	; new closure is in rax
	mov qword [free_var_74], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_373c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_373c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_373c
.L_lambda_simple_env_end_373c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_373c:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_373c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_373c
.L_lambda_simple_params_end_373c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_373c
	jmp .L_lambda_simple_end_373c
.L_lambda_simple_code_373c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_373c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_373c:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_57]
.L_applic_TC_3fd8:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fd8:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fd8
.L_tc_recycle_frame_done_3fd8:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_373c:	; new closure is in rax
	mov qword [free_var_75], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_373d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_373d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_373d
.L_lambda_simple_env_end_373d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_373d:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_373d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_373d
.L_lambda_simple_params_end_373d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_373d
	jmp .L_lambda_simple_end_373d
.L_lambda_simple_code_373d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_373d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_373d:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_58]
.L_applic_TC_3fd9:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fd9:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fd9
.L_tc_recycle_frame_done_3fd9:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_373d:	; new closure is in rax
	mov qword [free_var_76], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_373e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_373e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_373e
.L_lambda_simple_env_end_373e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_373e:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_373e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_373e
.L_lambda_simple_params_end_373e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_373e
	jmp .L_lambda_simple_end_373e
.L_lambda_simple_code_373e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_373e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_373e:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_58]
.L_applic_TC_3fda:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fda:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fda
.L_tc_recycle_frame_done_3fda:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_373e:	; new closure is in rax
	mov qword [free_var_77], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_373f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_373f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_373f
.L_lambda_simple_env_end_373f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_373f:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_373f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_373f
.L_lambda_simple_params_end_373f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_373f
	jmp .L_lambda_simple_end_373f
.L_lambda_simple_code_373f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_373f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_373f:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_58]
.L_applic_TC_3fdb:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fdb:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fdb
.L_tc_recycle_frame_done_3fdb:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_373f:	; new closure is in rax
	mov qword [free_var_78], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3740:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3740
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3740
.L_lambda_simple_env_end_3740:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3740:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3740
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3740
.L_lambda_simple_params_end_3740:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3740
	jmp .L_lambda_simple_end_3740
.L_lambda_simple_code_3740:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3740
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3740:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_58]
.L_applic_TC_3fdc:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fdc:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fdc
.L_tc_recycle_frame_done_3fdc:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3740:	; new closure is in rax
	mov qword [free_var_79], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3741:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3741
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3741
.L_lambda_simple_env_end_3741:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3741:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3741
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3741
.L_lambda_simple_params_end_3741:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3741
	jmp .L_lambda_simple_end_3741
.L_lambda_simple_code_3741:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3741
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3741:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_59]
.L_applic_TC_3fdd:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fdd:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fdd
.L_tc_recycle_frame_done_3fdd:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3741:	; new closure is in rax
	mov qword [free_var_80], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3742:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3742
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3742
.L_lambda_simple_env_end_3742:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3742:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3742
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3742
.L_lambda_simple_params_end_3742:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3742
	jmp .L_lambda_simple_end_3742
.L_lambda_simple_code_3742:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3742
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3742:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_59]
.L_applic_TC_3fde:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fde:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fde
.L_tc_recycle_frame_done_3fde:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3742:	; new closure is in rax
	mov qword [free_var_81], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3743:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3743
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3743
.L_lambda_simple_env_end_3743:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3743:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3743
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3743
.L_lambda_simple_params_end_3743:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3743
	jmp .L_lambda_simple_end_3743
.L_lambda_simple_code_3743:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3743
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3743:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_59]
.L_applic_TC_3fdf:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fdf:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fdf
.L_tc_recycle_frame_done_3fdf:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3743:	; new closure is in rax
	mov qword [free_var_82], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3744:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3744
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3744
.L_lambda_simple_env_end_3744:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3744:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3744
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3744
.L_lambda_simple_params_end_3744:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3744
	jmp .L_lambda_simple_end_3744
.L_lambda_simple_code_3744:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3744
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3744:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_59]
.L_applic_TC_3fe0:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fe0:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fe0
.L_tc_recycle_frame_done_3fe0:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3744:	; new closure is in rax
	mov qword [free_var_83], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3745:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3745
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3745
.L_lambda_simple_env_end_3745:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3745:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3745
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3745
.L_lambda_simple_params_end_3745:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3745
	jmp .L_lambda_simple_end_3745
.L_lambda_simple_code_3745:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3745
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3745:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0424
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47c5
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_84]
.L_applic_TC_3fe1:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fe1:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fe1
.L_tc_recycle_frame_done_3fe1:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47c5

        	.L_if_else_47c5:
	mov rax,L_constants + 2

        	.L_if_end_47c5:
.L_or_end_0424:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3745:	; new closure is in rax
	mov qword [free_var_84], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 0
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_087a:

        	cmp rsi, 0

        	je .L_lambda_opt_env_end_087a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_087a

        	.L_lambda_opt_env_end_087a:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_087a:

        	cmp rsi, 0

        	je .L_lambda_opt_params_end_087a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_087a

        	.L_lambda_opt_params_end_087a:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_087a

        	jmp .L_lambda_opt_end_087a

        	.L_lambda_opt_code_087a:

        	cmp qword [rsp + 8 * 2], 0

        	je .L_lambda_opt_arity_check_exact_087a  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_087a  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_087a:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_196c:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_196c
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_196c

        	.L_lambda_opt_stack_shrink_loop_exit_196c:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_087a

        	.L_lambda_opt_arity_check_more_087a:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 0]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_196d:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_196d
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_196d

        	.L_lambda_opt_stack_shrink_loop_exit_196d:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (0 + 2))]

        	mov rcx, 0 

        	.L_lambda_opt_stack_shrink_loop_196e:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_196e
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_196e

        	.L_lambda_opt_stack_shrink_loop_exit_196e:

        	mov qword [rdx], 1 + 0
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_087a:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_087a:	; new closure is in rax
	mov qword [free_var_85], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3746:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3746
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3746
.L_lambda_simple_env_end_3746:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3746:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3746
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3746
.L_lambda_simple_params_end_3746:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3746
	jmp .L_lambda_simple_end_3746
.L_lambda_simple_code_3746:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3746
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3746:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]

        	cmp rax, sob_boolean_false

        	je .L_if_else_47c6
	mov rax,L_constants + 2

        	jmp .L_if_end_47c6

        	.L_if_else_47c6:
	mov rax,L_constants + 3

        	.L_if_end_47c6:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3746:	; new closure is in rax
	mov qword [free_var_86], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3747:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3747
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3747
.L_lambda_simple_env_end_3747:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3747:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3747
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3747
.L_lambda_simple_params_end_3747:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3747
	jmp .L_lambda_simple_end_3747
.L_lambda_simple_code_3747:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3747
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3747:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47c7
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_28]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_86]
.L_applic_TC_3fe2:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fe2:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fe2
.L_tc_recycle_frame_done_3fe2:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47c7

        	.L_if_else_47c7:
	mov rax,L_constants + 2

        	.L_if_end_47c7:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3747:	; new closure is in rax
	mov qword [free_var_87], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3748:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3748
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3748
.L_lambda_simple_env_end_3748:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3748:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3748
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3748
.L_lambda_simple_params_end_3748:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3748
	jmp .L_lambda_simple_end_3748
.L_lambda_simple_code_3748:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3748
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3748:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3749:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_3749
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3749
.L_lambda_simple_env_end_3749:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3749:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3749
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3749
.L_lambda_simple_params_end_3749:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3749
	jmp .L_lambda_simple_end_3749
.L_lambda_simple_code_3749:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_3749
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3749:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47c8
	mov rax ,qword[rbp + 8 * (4 + 0)]

        	jmp .L_if_end_47c8

        	.L_if_else_47c8:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_13]
.L_applic_TC_3fe3:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fe3:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fe3
.L_tc_recycle_frame_done_3fe3:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47c8:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_3749:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	push rax
	mov rdi, 8 * 2
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_087b:

        	cmp rsi, 1

        	je .L_lambda_opt_env_end_087b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_087b

        	.L_lambda_opt_env_end_087b:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_087b:

        	cmp rsi, 1

        	je .L_lambda_opt_params_end_087b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_087b

        	.L_lambda_opt_params_end_087b:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_087b

        	jmp .L_lambda_opt_end_087b

        	.L_lambda_opt_code_087b:

        	cmp qword [rsp + 8 * 2], 1

        	je .L_lambda_opt_arity_check_exact_087b  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_087b  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_087b:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_196f:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_196f
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_196f

        	.L_lambda_opt_stack_shrink_loop_exit_196f:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_087b

        	.L_lambda_opt_arity_check_more_087b:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 1]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_1970:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1970
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_1970

        	.L_lambda_opt_stack_shrink_loop_exit_1970:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (1 + 2))]

        	mov rcx, 1 

        	.L_lambda_opt_stack_shrink_loop_1971:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1971
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_1971

        	.L_lambda_opt_stack_shrink_loop_exit_1971:

        	mov qword [rdx], 1 + 1
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_087b:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_3fe4:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fe4:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fe4
.L_tc_recycle_frame_done_3fe4:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_087b:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3748:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_88], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_374a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_374a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_374a
.L_lambda_simple_env_end_374a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_374a:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_374a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_374a
.L_lambda_simple_params_end_374a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_374a
	jmp .L_lambda_simple_end_374a
.L_lambda_simple_code_374a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_374a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_374a:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_374b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_374b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_374b
.L_lambda_simple_env_end_374b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_374b:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_374b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_374b
.L_lambda_simple_params_end_374b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_374b
	jmp .L_lambda_simple_end_374b
.L_lambda_simple_code_374b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_374b
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_374b:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47c9
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_13]
.L_applic_TC_3fe5:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fe5:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fe5
.L_tc_recycle_frame_done_3fe5:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47c9

        	.L_if_else_47c9:
	mov rax ,qword[rbp + 8 * (4 + 0)]

        	.L_if_end_47c9:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_374b:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	push rax
	mov rdi, 8 * 2
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_087c:

        	cmp rsi, 1

        	je .L_lambda_opt_env_end_087c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_087c

        	.L_lambda_opt_env_end_087c:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_087c:

        	cmp rsi, 1

        	je .L_lambda_opt_params_end_087c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_087c

        	.L_lambda_opt_params_end_087c:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_087c

        	jmp .L_lambda_opt_end_087c

        	.L_lambda_opt_code_087c:

        	cmp qword [rsp + 8 * 2], 1

        	je .L_lambda_opt_arity_check_exact_087c  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_087c  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_087c:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_1972:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1972
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_1972

        	.L_lambda_opt_stack_shrink_loop_exit_1972:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_087c

        	.L_lambda_opt_arity_check_more_087c:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 1]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_1973:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1973
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_1973

        	.L_lambda_opt_stack_shrink_loop_exit_1973:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (1 + 2))]

        	mov rcx, 1 

        	.L_lambda_opt_stack_shrink_loop_1974:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1974
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_1974

        	.L_lambda_opt_stack_shrink_loop_exit_1974:

        	mov qword [rdx], 1 + 1
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_087c:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_29]
.L_applic_TC_3fe6:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fe6:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fe6
.L_tc_recycle_frame_done_3fe6:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_087c:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_374a:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_89], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 0
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_087d:

        	cmp rsi, 0

        	je .L_lambda_opt_env_end_087d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_087d

        	.L_lambda_opt_env_end_087d:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_087d:

        	cmp rsi, 0

        	je .L_lambda_opt_params_end_087d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_087d

        	.L_lambda_opt_params_end_087d:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_087d

        	jmp .L_lambda_opt_end_087d

        	.L_lambda_opt_code_087d:

        	cmp qword [rsp + 8 * 2], 1

        	je .L_lambda_opt_arity_check_exact_087d  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_087d  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_087d:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_1975:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1975
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_1975

        	.L_lambda_opt_stack_shrink_loop_exit_1975:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_087d

        	.L_lambda_opt_arity_check_more_087d:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 1]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_1976:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1976
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_1976

        	.L_lambda_opt_stack_shrink_loop_exit_1976:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (1 + 2))]

        	mov rcx, 1 

        	.L_lambda_opt_stack_shrink_loop_1977:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1977
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_1977

        	.L_lambda_opt_stack_shrink_loop_exit_1977:

        	mov qword [rdx], 1 + 1
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_087d:
	enter 0, 0
	mov rax,L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_374c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_374c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_374c
.L_lambda_simple_env_end_374c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_374c:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_374c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_374c
.L_lambda_simple_params_end_374c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_374c
	jmp .L_lambda_simple_end_374c
.L_lambda_simple_code_374c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_374c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_374c:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_374d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_374d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_374d
.L_lambda_simple_env_end_374d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_374d:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_374d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_374d
.L_lambda_simple_params_end_374d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_374d
	jmp .L_lambda_simple_end_374d
.L_lambda_simple_code_374d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_374d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_374d:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47ca
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [free_var_89]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0425
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_3fe7:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fe7:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fe7
.L_tc_recycle_frame_done_3fe7:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
.L_or_end_0425:

        	jmp .L_if_end_47ca

        	.L_if_else_47ca:
	mov rax,L_constants + 2

        	.L_if_end_47ca:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_374d:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 1]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	mov rax, qword [rax]
.L_applic_TC_3fe8:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fe8:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fe8
.L_tc_recycle_frame_done_3fe8:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_374c:	; new closure is in rax
.L_applic_TC_3fe9:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fe9:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fe9
.L_tc_recycle_frame_done_3fe9:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_087d:	; new closure is in rax
	mov qword [free_var_90], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 0
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_087e:

        	cmp rsi, 0

        	je .L_lambda_opt_env_end_087e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_087e

        	.L_lambda_opt_env_end_087e:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_087e:

        	cmp rsi, 0

        	je .L_lambda_opt_params_end_087e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_087e

        	.L_lambda_opt_params_end_087e:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_087e

        	jmp .L_lambda_opt_end_087e

        	.L_lambda_opt_code_087e:

        	cmp qword [rsp + 8 * 2], 1

        	je .L_lambda_opt_arity_check_exact_087e  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_087e  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_087e:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_1978:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1978
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_1978

        	.L_lambda_opt_stack_shrink_loop_exit_1978:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_087e

        	.L_lambda_opt_arity_check_more_087e:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 1]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_1979:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1979
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_1979

        	.L_lambda_opt_stack_shrink_loop_exit_1979:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (1 + 2))]

        	mov rcx, 1 

        	.L_lambda_opt_stack_shrink_loop_197a:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_197a
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_197a

        	.L_lambda_opt_stack_shrink_loop_exit_197a:

        	mov qword [rdx], 1 + 1
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_087e:
	enter 0, 0
	mov rax,L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_374e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_374e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_374e
.L_lambda_simple_env_end_374e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_374e:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_374e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_374e
.L_lambda_simple_params_end_374e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_374e
	jmp .L_lambda_simple_end_374e
.L_lambda_simple_code_374e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_374e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_374e:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_374f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_374f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_374f
.L_lambda_simple_env_end_374f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_374f:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_374f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_374f
.L_lambda_simple_params_end_374f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_374f
	jmp .L_lambda_simple_end_374f
.L_lambda_simple_code_374f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_374f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_374f:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0426
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [free_var_89]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47cb
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_3fea:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fea:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fea
.L_tc_recycle_frame_done_3fea:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47cb

        	.L_if_else_47cb:
	mov rax,L_constants + 2

        	.L_if_end_47cb:
.L_or_end_0426:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_374f:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 1]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	mov rax, qword [rax]
.L_applic_TC_3feb:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3feb:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3feb
.L_tc_recycle_frame_done_3feb:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_374e:	; new closure is in rax
.L_applic_TC_3fec:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fec:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fec
.L_tc_recycle_frame_done_3fec:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_087e:	; new closure is in rax
	mov qword [free_var_92], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 23
	push rax
	mov rax,L_constants + 23
	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3750:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3750
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3750
.L_lambda_simple_env_end_3750:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3750:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3750
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3750
.L_lambda_simple_params_end_3750:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3750
	jmp .L_lambda_simple_end_3750
.L_lambda_simple_code_3750:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_3750
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3750:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, 8
	call malloc
	mov rbx, PARAM(1)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 1)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3751:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_3751
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3751
.L_lambda_simple_env_end_3751:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3751:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_3751
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3751
.L_lambda_simple_params_end_3751:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3751
	jmp .L_lambda_simple_end_3751
.L_lambda_simple_code_3751:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_3751
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3751:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47cc
	mov rax,L_constants + 1

        	jmp .L_if_end_47cc

        	.L_if_else_47cc:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
.L_applic_TC_3fed:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fed:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fed
.L_tc_recycle_frame_done_3fed:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47cc:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_3751:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3752:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_3752
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3752
.L_lambda_simple_env_end_3752:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3752:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_3752
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3752
.L_lambda_simple_params_end_3752:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3752
	jmp .L_lambda_simple_end_3752
.L_lambda_simple_code_3752:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_3752
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3752:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47cd
	mov rax,L_constants + 1

        	jmp .L_if_end_47cd

        	.L_if_else_47cd:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 1]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_89]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
.L_applic_TC_3fee:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fee:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fee
.L_tc_recycle_frame_done_3fee:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47cd:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_3752:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 2
	call malloc
	push rax
	mov rdi, 8 * 2
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_087f:

        	cmp rsi, 1

        	je .L_lambda_opt_env_end_087f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_087f

        	.L_lambda_opt_env_end_087f:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_087f:

        	cmp rsi, 2

        	je .L_lambda_opt_params_end_087f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_087f

        	.L_lambda_opt_params_end_087f:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_087f

        	jmp .L_lambda_opt_end_087f

        	.L_lambda_opt_code_087f:

        	cmp qword [rsp + 8 * 2], 1

        	je .L_lambda_opt_arity_check_exact_087f  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_087f  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_087f:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_197b:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_197b
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_197b

        	.L_lambda_opt_stack_shrink_loop_exit_197b:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_087f

        	.L_lambda_opt_arity_check_more_087f:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 1]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_197c:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_197c
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_197c

        	.L_lambda_opt_stack_shrink_loop_exit_197c:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (1 + 2))]

        	mov rcx, 1 

        	.L_lambda_opt_stack_shrink_loop_197d:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_197d
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_197d

        	.L_lambda_opt_stack_shrink_loop_exit_197d:

        	mov qword [rdx], 1 + 1
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_087f:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47ce
	mov rax,L_constants + 1

        	jmp .L_if_end_47ce

        	.L_if_else_47ce:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 1]
	mov rax, qword [rax]
.L_applic_TC_3fef:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fef:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fef
.L_tc_recycle_frame_done_3fef:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47ce:
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_087f:	; new closure is in rax
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_3750:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_91], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3753:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3753
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3753
.L_lambda_simple_env_end_3753:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3753:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3753
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3753
.L_lambda_simple_params_end_3753:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3753
	jmp .L_lambda_simple_end_3753
.L_lambda_simple_code_3753:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3753
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3753:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3754:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_3754
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3754
.L_lambda_simple_env_end_3754:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3754:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3754
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3754
.L_lambda_simple_params_end_3754:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3754
	jmp .L_lambda_simple_end_3754
.L_lambda_simple_code_3754:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_3754
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3754:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47cf
	mov rax ,qword[rbp + 8 * (4 + 1)]

        	jmp .L_if_end_47cf

        	.L_if_else_47cf:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_3ff0:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3ff0:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3ff0
.L_tc_recycle_frame_done_3ff0:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47cf:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_3754:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3755:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_3755
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3755
.L_lambda_simple_env_end_3755:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3755:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3755
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3755
.L_lambda_simple_params_end_3755:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3755
	jmp .L_lambda_simple_end_3755
.L_lambda_simple_code_3755:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3755
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3755:
	enter 0, 0
	mov rax,L_constants + 1
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_3ff1:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3ff1:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3ff1
.L_tc_recycle_frame_done_3ff1:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3755:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3753:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_93], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 23
	push rax
	mov rax,L_constants + 23
	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3756:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3756
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3756
.L_lambda_simple_env_end_3756:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3756:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3756
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3756
.L_lambda_simple_params_end_3756:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3756
	jmp .L_lambda_simple_end_3756
.L_lambda_simple_code_3756:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_3756
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3756:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, 8
	call malloc
	mov rbx, PARAM(1)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 1)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3757:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_3757
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3757
.L_lambda_simple_env_end_3757:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3757:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_3757
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3757
.L_lambda_simple_params_end_3757:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3757
	jmp .L_lambda_simple_end_3757
.L_lambda_simple_code_3757:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_3757
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3757:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47d0
	mov rax ,qword[rbp + 8 * (4 + 0)]

        	jmp .L_if_end_47d0

        	.L_if_else_47d0:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 1]
	mov rax, qword [rax]
.L_applic_TC_3ff2:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3ff2:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3ff2
.L_tc_recycle_frame_done_3ff2:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47d0:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_3757:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3758:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_3758
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3758
.L_lambda_simple_env_end_3758:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3758:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_3758
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3758
.L_lambda_simple_params_end_3758:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3758
	jmp .L_lambda_simple_end_3758
.L_lambda_simple_code_3758:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_3758
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3758:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47d1
	mov rax ,qword[rbp + 8 * (4 + 1)]

        	jmp .L_if_end_47d1

        	.L_if_else_47d1:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 1]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
.L_applic_TC_3ff3:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3ff3:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3ff3
.L_tc_recycle_frame_done_3ff3:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47d1:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_3758:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 2
	call malloc
	push rax
	mov rdi, 8 * 2
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_0880:

        	cmp rsi, 1

        	je .L_lambda_opt_env_end_0880
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_0880

        	.L_lambda_opt_env_end_0880:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_0880:

        	cmp rsi, 2

        	je .L_lambda_opt_params_end_0880
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_0880

        	.L_lambda_opt_params_end_0880:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0880

        	jmp .L_lambda_opt_end_0880

        	.L_lambda_opt_code_0880:

        	cmp qword [rsp + 8 * 2], 0

        	je .L_lambda_opt_arity_check_exact_0880  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_0880  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_0880:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_197e:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_197e
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_197e

        	.L_lambda_opt_stack_shrink_loop_exit_197e:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0880

        	.L_lambda_opt_arity_check_more_0880:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 0]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_197f:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_197f
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_197f

        	.L_lambda_opt_stack_shrink_loop_exit_197f:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (0 + 2))]

        	mov rcx, 0 

        	.L_lambda_opt_stack_shrink_loop_1980:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1980
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_1980

        	.L_lambda_opt_stack_shrink_loop_exit_1980:

        	mov qword [rdx], 1 + 0
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_0880:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47d2
	mov rax,L_constants + 1

        	jmp .L_if_end_47d2

        	.L_if_else_47d2:
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_3ff4:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3ff4:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3ff4
.L_tc_recycle_frame_done_3ff4:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47d2:
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0880:	; new closure is in rax
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_3756:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_94], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3759:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3759
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3759
.L_lambda_simple_env_end_3759:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3759:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3759
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3759
.L_lambda_simple_params_end_3759:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3759
	jmp .L_lambda_simple_end_3759
.L_lambda_simple_code_3759:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3759
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3759:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_375a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_375a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_375a
.L_lambda_simple_env_end_375a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_375a:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_375a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_375a
.L_lambda_simple_params_end_375a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_375a
	jmp .L_lambda_simple_end_375a
.L_lambda_simple_code_375a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_375a
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_375a:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [free_var_0]
	push rax
	push 2
	mov rax, qword [free_var_90]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47d3
	mov rax ,qword[rbp + 8 * (4 + 1)]

        	jmp .L_if_end_47d3

        	.L_if_else_47d3:
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [free_var_89]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_3ff5:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3ff5:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3ff5
.L_tc_recycle_frame_done_3ff5:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47d3:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_375a:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	push rax
	mov rdi, 8 * 2
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_0881:

        	cmp rsi, 1

        	je .L_lambda_opt_env_end_0881
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_0881

        	.L_lambda_opt_env_end_0881:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_0881:

        	cmp rsi, 1

        	je .L_lambda_opt_params_end_0881
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_0881

        	.L_lambda_opt_params_end_0881:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0881

        	jmp .L_lambda_opt_end_0881

        	.L_lambda_opt_code_0881:

        	cmp qword [rsp + 8 * 2], 2

        	je .L_lambda_opt_arity_check_exact_0881  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_0881  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_0881:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_1981:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1981
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_1981

        	.L_lambda_opt_stack_shrink_loop_exit_1981:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0881

        	.L_lambda_opt_arity_check_more_0881:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 2]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_1982:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1982
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_1982

        	.L_lambda_opt_stack_shrink_loop_exit_1982:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (2 + 2))]

        	mov rcx, 2 

        	.L_lambda_opt_stack_shrink_loop_1983:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1983
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_1983

        	.L_lambda_opt_stack_shrink_loop_exit_1983:

        	mov qword [rdx], 1 + 2
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_0881:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_3ff6:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3ff6:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3ff6
.L_tc_recycle_frame_done_3ff6:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 3)
.L_lambda_opt_end_0881:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3759:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_95], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_375b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_375b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_375b
.L_lambda_simple_env_end_375b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_375b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_375b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_375b
.L_lambda_simple_params_end_375b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_375b
	jmp .L_lambda_simple_end_375b
.L_lambda_simple_code_375b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_375b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_375b:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_375c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_375c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_375c
.L_lambda_simple_env_end_375c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_375c:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_375c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_375c
.L_lambda_simple_params_end_375c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_375c
	jmp .L_lambda_simple_end_375c
.L_lambda_simple_code_375c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_375c
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_375c:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [free_var_0]
	push rax
	push 2
	mov rax, qword [free_var_90]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47d4
	mov rax ,qword[rbp + 8 * (4 + 1)]

        	jmp .L_if_end_47d4

        	.L_if_else_47d4:
	mov rax,L_constants + 1
	push rax
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_94]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_89]
.L_applic_TC_3ff7:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3ff7:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3ff7
.L_tc_recycle_frame_done_3ff7:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47d4:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_375c:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	push rax
	mov rdi, 8 * 2
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_0882:

        	cmp rsi, 1

        	je .L_lambda_opt_env_end_0882
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_0882

        	.L_lambda_opt_env_end_0882:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_0882:

        	cmp rsi, 1

        	je .L_lambda_opt_params_end_0882
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_0882

        	.L_lambda_opt_params_end_0882:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0882

        	jmp .L_lambda_opt_end_0882

        	.L_lambda_opt_code_0882:

        	cmp qword [rsp + 8 * 2], 2

        	je .L_lambda_opt_arity_check_exact_0882  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_0882  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_0882:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_1984:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1984
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_1984

        	.L_lambda_opt_stack_shrink_loop_exit_1984:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0882

        	.L_lambda_opt_arity_check_more_0882:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 2]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_1985:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1985
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_1985

        	.L_lambda_opt_stack_shrink_loop_exit_1985:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (2 + 2))]

        	mov rcx, 2 

        	.L_lambda_opt_stack_shrink_loop_1986:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1986
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_1986

        	.L_lambda_opt_stack_shrink_loop_exit_1986:

        	mov qword [rdx], 1 + 2
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_0882:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_3ff8:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3ff8:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3ff8
.L_tc_recycle_frame_done_3ff8:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 3)
.L_lambda_opt_end_0882:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_375b:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_96], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_375d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_375d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_375d
.L_lambda_simple_env_end_375d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_375d:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_375d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_375d
.L_lambda_simple_params_end_375d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_375d
	jmp .L_lambda_simple_end_375d
.L_lambda_simple_code_375d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_375d
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_375d:
	enter 0, 0
	mov rax,L_constants + 68
	push rax
	mov rax,L_constants + 59
	push rax
	push 2
	mov rax, qword [free_var_38]
.L_applic_TC_3ff9:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3ff9:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3ff9
.L_tc_recycle_frame_done_3ff9:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_375d:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_375e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_375e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_375e
.L_lambda_simple_env_end_375e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_375e:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_375e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_375e
.L_lambda_simple_params_end_375e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_375e
	jmp .L_lambda_simple_end_375e
.L_lambda_simple_code_375e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_375e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_375e:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_375f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_375f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_375f
.L_lambda_simple_env_end_375f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_375f:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_375f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_375f
.L_lambda_simple_params_end_375f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_375f
	jmp .L_lambda_simple_end_375f
.L_lambda_simple_code_375f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_375f
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_375f:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47d5
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47d9
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_34]
.L_applic_TC_4000:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4000:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4000
.L_tc_recycle_frame_done_4000:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47d9

        	.L_if_else_47d9:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47da
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_30]
.L_applic_TC_3fff:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3fff:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3fff
.L_tc_recycle_frame_done_3fff:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47da

        	.L_if_else_47da:
	push 0
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_3ffe:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3ffe:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3ffe
.L_tc_recycle_frame_done_3ffe:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47da:

        	.L_if_end_47d9:

        	jmp .L_if_end_47d5

        	.L_if_else_47d5:
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47d6
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47d7
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_30]
.L_applic_TC_3ffd:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3ffd:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3ffd
.L_tc_recycle_frame_done_3ffd:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47d7

        	.L_if_else_47d7:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47d8
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_30]
.L_applic_TC_3ffc:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3ffc:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3ffc
.L_tc_recycle_frame_done_3ffc:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47d8

        	.L_if_else_47d8:
	push 0
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_3ffb:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3ffb:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3ffb
.L_tc_recycle_frame_done_3ffb:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47d8:

        	.L_if_end_47d7:

        	jmp .L_if_end_47d6

        	.L_if_else_47d6:
	push 0
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_3ffa:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_3ffa:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_3ffa
.L_tc_recycle_frame_done_3ffa:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47d6:

        	.L_if_end_47d5:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_375f:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3760:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_3760
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3760
.L_lambda_simple_env_end_3760:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3760:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3760
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3760
.L_lambda_simple_params_end_3760:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3760
	jmp .L_lambda_simple_end_3760
.L_lambda_simple_code_3760:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3760
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3760:
	enter 0, 0
	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	push rax
	mov rdi, 8 * 3
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_0883:

        	cmp rsi, 2

        	je .L_lambda_opt_env_end_0883
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_0883

        	.L_lambda_opt_env_end_0883:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_0883:

        	cmp rsi, 1

        	je .L_lambda_opt_params_end_0883
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_0883

        	.L_lambda_opt_params_end_0883:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0883

        	jmp .L_lambda_opt_end_0883

        	.L_lambda_opt_code_0883:

        	cmp qword [rsp + 8 * 2], 0

        	je .L_lambda_opt_arity_check_exact_0883  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_0883  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_0883:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_1987:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1987
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_1987

        	.L_lambda_opt_stack_shrink_loop_exit_1987:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0883

        	.L_lambda_opt_arity_check_more_0883:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 0]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_1988:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1988
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_1988

        	.L_lambda_opt_stack_shrink_loop_exit_1988:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (0 + 2))]

        	mov rcx, 0 

        	.L_lambda_opt_stack_shrink_loop_1989:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1989
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_1989

        	.L_lambda_opt_stack_shrink_loop_exit_1989:

        	mov qword [rdx], 1 + 0
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_0883:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax,L_constants + 32
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	push 3
	mov rax, qword [free_var_95]
.L_applic_TC_4001:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4001:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4001
.L_tc_recycle_frame_done_4001:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0883:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3760:	; new closure is in rax
.L_applic_TC_4002:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4002:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4002
.L_tc_recycle_frame_done_4002:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_375e:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_97], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3761:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3761
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3761
.L_lambda_simple_env_end_3761:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3761:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3761
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3761
.L_lambda_simple_params_end_3761:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3761
	jmp .L_lambda_simple_end_3761
.L_lambda_simple_code_3761:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_3761
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3761:
	enter 0, 0
	mov rax,L_constants + 68
	push rax
	mov rax,L_constants + 119
	push rax
	push 2
	mov rax, qword [free_var_38]
.L_applic_TC_4003:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4003:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4003
.L_tc_recycle_frame_done_4003:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_3761:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3762:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3762
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3762
.L_lambda_simple_env_end_3762:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3762:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3762
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3762
.L_lambda_simple_params_end_3762:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3762
	jmp .L_lambda_simple_end_3762
.L_lambda_simple_code_3762:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3762
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3762:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3763:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_3763
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3763
.L_lambda_simple_env_end_3763:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3763:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3763
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3763
.L_lambda_simple_params_end_3763:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3763
	jmp .L_lambda_simple_end_3763
.L_lambda_simple_code_3763:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_3763
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3763:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47db
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47df
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_35]
.L_applic_TC_400a:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_400a:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_400a
.L_tc_recycle_frame_done_400a:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47df

        	.L_if_else_47df:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47e0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_31]
.L_applic_TC_4009:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4009:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4009
.L_tc_recycle_frame_done_4009:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47e0

        	.L_if_else_47e0:
	push 0
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_4008:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4008:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4008
.L_tc_recycle_frame_done_4008:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47e0:

        	.L_if_end_47df:

        	jmp .L_if_end_47db

        	.L_if_else_47db:
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47dc
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47dd
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_31]
.L_applic_TC_4007:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4007:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4007
.L_tc_recycle_frame_done_4007:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47dd

        	.L_if_else_47dd:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47de
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_31]
.L_applic_TC_4006:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4006:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4006
.L_tc_recycle_frame_done_4006:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47de

        	.L_if_else_47de:
	push 0
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_4005:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4005:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4005
.L_tc_recycle_frame_done_4005:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47de:

        	.L_if_end_47dd:

        	jmp .L_if_end_47dc

        	.L_if_else_47dc:
	push 0
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_4004:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4004:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4004
.L_tc_recycle_frame_done_4004:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47dc:

        	.L_if_end_47db:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_3763:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3764:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_3764
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3764
.L_lambda_simple_env_end_3764:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3764:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3764
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3764
.L_lambda_simple_params_end_3764:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3764
	jmp .L_lambda_simple_end_3764
.L_lambda_simple_code_3764:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3764
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3764:
	enter 0, 0
	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	push rax
	mov rdi, 8 * 3
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_0884:

        	cmp rsi, 2

        	je .L_lambda_opt_env_end_0884
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_0884

        	.L_lambda_opt_env_end_0884:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_0884:

        	cmp rsi, 1

        	je .L_lambda_opt_params_end_0884
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_0884

        	.L_lambda_opt_params_end_0884:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0884

        	jmp .L_lambda_opt_end_0884

        	.L_lambda_opt_code_0884:

        	cmp qword [rsp + 8 * 2], 1

        	je .L_lambda_opt_arity_check_exact_0884  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_0884  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_0884:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_198a:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_198a
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_198a

        	.L_lambda_opt_stack_shrink_loop_exit_198a:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0884

        	.L_lambda_opt_arity_check_more_0884:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 1]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_198b:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_198b
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_198b

        	.L_lambda_opt_stack_shrink_loop_exit_198b:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (1 + 2))]

        	mov rcx, 1 

        	.L_lambda_opt_stack_shrink_loop_198c:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_198c
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_198c

        	.L_lambda_opt_stack_shrink_loop_exit_198c:

        	mov qword [rdx], 1 + 1
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_0884:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47e1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax,L_constants + 32
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_400d:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_400d:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_400d
.L_tc_recycle_frame_done_400d:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47e1

        	.L_if_else_47e1:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax,L_constants + 32
	push rax
	mov rax, qword [free_var_97]
	push rax
	push 3
	mov rax, qword [free_var_95]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3765:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_3765
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3765
.L_lambda_simple_env_end_3765:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3765:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_3765
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3765
.L_lambda_simple_params_end_3765:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3765
	jmp .L_lambda_simple_end_3765
.L_lambda_simple_code_3765:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3765
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3765:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_400b:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_400b:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_400b
.L_tc_recycle_frame_done_400b:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3765:	; new closure is in rax
.L_applic_TC_400c:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_400c:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_400c
.L_tc_recycle_frame_done_400c:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47e1:
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0884:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3764:	; new closure is in rax
.L_applic_TC_400e:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_400e:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_400e
.L_tc_recycle_frame_done_400e:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3762:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_98], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3766:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3766
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3766
.L_lambda_simple_env_end_3766:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3766:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3766
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3766
.L_lambda_simple_params_end_3766:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3766
	jmp .L_lambda_simple_end_3766
.L_lambda_simple_code_3766:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_3766
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3766:
	enter 0, 0
	mov rax,L_constants + 68
	push rax
	mov rax,L_constants + 155
	push rax
	push 2
	mov rax, qword [free_var_38]
.L_applic_TC_400f:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_400f:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_400f
.L_tc_recycle_frame_done_400f:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_3766:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3767:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3767
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3767
.L_lambda_simple_env_end_3767:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3767:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3767
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3767
.L_lambda_simple_params_end_3767:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3767
	jmp .L_lambda_simple_end_3767
.L_lambda_simple_code_3767:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3767
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3767:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3768:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_3768
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3768
.L_lambda_simple_env_end_3768:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3768:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3768
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3768
.L_lambda_simple_params_end_3768:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3768
	jmp .L_lambda_simple_end_3768
.L_lambda_simple_code_3768:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_3768
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3768:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47e2
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47e6
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_36]
.L_applic_TC_4016:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4016:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4016
.L_tc_recycle_frame_done_4016:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47e6

        	.L_if_else_47e6:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47e7
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_32]
.L_applic_TC_4015:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4015:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4015
.L_tc_recycle_frame_done_4015:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47e7

        	.L_if_else_47e7:
	push 0
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_4014:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4014:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4014
.L_tc_recycle_frame_done_4014:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47e7:

        	.L_if_end_47e6:

        	jmp .L_if_end_47e2

        	.L_if_else_47e2:
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47e3
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47e4
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_32]
.L_applic_TC_4013:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4013:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4013
.L_tc_recycle_frame_done_4013:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47e4

        	.L_if_else_47e4:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47e5
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_32]
.L_applic_TC_4012:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4012:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4012
.L_tc_recycle_frame_done_4012:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47e5

        	.L_if_else_47e5:
	push 0
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_4011:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4011:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4011
.L_tc_recycle_frame_done_4011:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47e5:

        	.L_if_end_47e4:

        	jmp .L_if_end_47e3

        	.L_if_else_47e3:
	push 0
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_4010:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4010:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4010
.L_tc_recycle_frame_done_4010:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47e3:

        	.L_if_end_47e2:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_3768:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3769:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_3769
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3769
.L_lambda_simple_env_end_3769:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3769:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3769
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3769
.L_lambda_simple_params_end_3769:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3769
	jmp .L_lambda_simple_end_3769
.L_lambda_simple_code_3769:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3769
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3769:
	enter 0, 0
	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	push rax
	mov rdi, 8 * 3
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_0885:

        	cmp rsi, 2

        	je .L_lambda_opt_env_end_0885
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_0885

        	.L_lambda_opt_env_end_0885:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_0885:

        	cmp rsi, 1

        	je .L_lambda_opt_params_end_0885
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_0885

        	.L_lambda_opt_params_end_0885:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0885

        	jmp .L_lambda_opt_end_0885

        	.L_lambda_opt_code_0885:

        	cmp qword [rsp + 8 * 2], 0

        	je .L_lambda_opt_arity_check_exact_0885  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_0885  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_0885:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_198d:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_198d
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_198d

        	.L_lambda_opt_stack_shrink_loop_exit_198d:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0885

        	.L_lambda_opt_arity_check_more_0885:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 0]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_198e:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_198e
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_198e

        	.L_lambda_opt_stack_shrink_loop_exit_198e:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (0 + 2))]

        	mov rcx, 0 

        	.L_lambda_opt_stack_shrink_loop_198f:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_198f
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_198f

        	.L_lambda_opt_stack_shrink_loop_exit_198f:

        	mov qword [rdx], 1 + 0
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_0885:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax,L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	push 3
	mov rax, qword [free_var_95]
.L_applic_TC_4017:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4017:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4017
.L_tc_recycle_frame_done_4017:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0885:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3769:	; new closure is in rax
.L_applic_TC_4018:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4018:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4018
.L_tc_recycle_frame_done_4018:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3767:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_99], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_376a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_376a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_376a
.L_lambda_simple_env_end_376a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_376a:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_376a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_376a
.L_lambda_simple_params_end_376a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_376a
	jmp .L_lambda_simple_end_376a
.L_lambda_simple_code_376a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_376a
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_376a:
	enter 0, 0
	mov rax,L_constants + 68
	push rax
	mov rax,L_constants + 174
	push rax
	push 2
	mov rax, qword [free_var_38]
.L_applic_TC_4019:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4019:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4019
.L_tc_recycle_frame_done_4019:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_376a:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_376b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_376b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_376b
.L_lambda_simple_env_end_376b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_376b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_376b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_376b
.L_lambda_simple_params_end_376b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_376b
	jmp .L_lambda_simple_end_376b
.L_lambda_simple_code_376b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_376b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_376b:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_376c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_376c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_376c
.L_lambda_simple_env_end_376c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_376c:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_376c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_376c
.L_lambda_simple_params_end_376c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_376c
	jmp .L_lambda_simple_end_376c
.L_lambda_simple_code_376c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_376c
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_376c:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47e8
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47ec
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_37]
.L_applic_TC_4020:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4020:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4020
.L_tc_recycle_frame_done_4020:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47ec

        	.L_if_else_47ec:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47ed
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_33]
.L_applic_TC_401f:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_401f:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_401f
.L_tc_recycle_frame_done_401f:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47ed

        	.L_if_else_47ed:
	push 0
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_401e:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_401e:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_401e
.L_tc_recycle_frame_done_401e:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47ed:

        	.L_if_end_47ec:

        	jmp .L_if_end_47e8

        	.L_if_else_47e8:
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47e9
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47ea
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_33]
.L_applic_TC_401d:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_401d:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_401d
.L_tc_recycle_frame_done_401d:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47ea

        	.L_if_else_47ea:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47eb
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_33]
.L_applic_TC_401c:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_401c:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_401c
.L_tc_recycle_frame_done_401c:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47eb

        	.L_if_else_47eb:
	push 0
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_401b:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_401b:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_401b
.L_tc_recycle_frame_done_401b:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47eb:

        	.L_if_end_47ea:

        	jmp .L_if_end_47e9

        	.L_if_else_47e9:
	push 0
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_401a:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_401a:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_401a
.L_tc_recycle_frame_done_401a:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47e9:

        	.L_if_end_47e8:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_376c:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_376d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_376d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_376d
.L_lambda_simple_env_end_376d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_376d:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_376d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_376d
.L_lambda_simple_params_end_376d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_376d
	jmp .L_lambda_simple_end_376d
.L_lambda_simple_code_376d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_376d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_376d:
	enter 0, 0
	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	push rax
	mov rdi, 8 * 3
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_0886:

        	cmp rsi, 2

        	je .L_lambda_opt_env_end_0886
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_0886

        	.L_lambda_opt_env_end_0886:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_0886:

        	cmp rsi, 1

        	je .L_lambda_opt_params_end_0886
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_0886

        	.L_lambda_opt_params_end_0886:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0886

        	jmp .L_lambda_opt_end_0886

        	.L_lambda_opt_code_0886:

        	cmp qword [rsp + 8 * 2], 1

        	je .L_lambda_opt_arity_check_exact_0886  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_0886  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_0886:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_1990:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1990
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_1990

        	.L_lambda_opt_stack_shrink_loop_exit_1990:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0886

        	.L_lambda_opt_arity_check_more_0886:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 1]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_1991:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1991
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_1991

        	.L_lambda_opt_stack_shrink_loop_exit_1991:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (1 + 2))]

        	mov rcx, 1 

        	.L_lambda_opt_stack_shrink_loop_1992:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1992
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_1992

        	.L_lambda_opt_stack_shrink_loop_exit_1992:

        	mov qword [rdx], 1 + 1
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_0886:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47ee
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax,L_constants + 128
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_4023:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4023:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4023
.L_tc_recycle_frame_done_4023:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47ee

        	.L_if_else_47ee:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax,L_constants + 128
	push rax
	mov rax, qword [free_var_99]
	push rax
	push 3
	mov rax, qword [free_var_95]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_376e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_376e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_376e
.L_lambda_simple_env_end_376e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_376e:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_376e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_376e
.L_lambda_simple_params_end_376e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_376e
	jmp .L_lambda_simple_end_376e
.L_lambda_simple_code_376e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_376e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_376e:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_4021:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4021:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4021
.L_tc_recycle_frame_done_4021:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_376e:	; new closure is in rax
.L_applic_TC_4022:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4022:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4022
.L_tc_recycle_frame_done_4022:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47ee:
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0886:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_376d:	; new closure is in rax
.L_applic_TC_4024:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4024:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4024
.L_tc_recycle_frame_done_4024:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_376b:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_100], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_376f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_376f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_376f
.L_lambda_simple_env_end_376f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_376f:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_376f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_376f
.L_lambda_simple_params_end_376f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_376f
	jmp .L_lambda_simple_end_376f
.L_lambda_simple_code_376f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_376f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_376f:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_27]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47ef
	mov rax,L_constants + 128

        	jmp .L_if_end_47ef

        	.L_if_else_47ef:
	mov rax,L_constants + 128
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_98]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_101]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_99]
.L_applic_TC_4025:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4025:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4025
.L_tc_recycle_frame_done_4025:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47ef:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_376f:	; new closure is in rax
	mov qword [free_var_101], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_102], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_103], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_104], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_105], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_106], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3770:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3770
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3770
.L_lambda_simple_env_end_3770:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3770:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3770
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3770
.L_lambda_simple_params_end_3770:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3770
	jmp .L_lambda_simple_end_3770
.L_lambda_simple_code_3770:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_3770
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3770:
	enter 0, 0
	mov rax,L_constants + 219
	push rax
	mov rax,L_constants + 210
	push rax
	push 2
	mov rax, qword [free_var_38]
.L_applic_TC_4026:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4026:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4026
.L_tc_recycle_frame_done_4026:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_3770:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3771:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3771
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3771
.L_lambda_simple_env_end_3771:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3771:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3771
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3771
.L_lambda_simple_params_end_3771:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3771
	jmp .L_lambda_simple_end_3771
.L_lambda_simple_code_3771:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3771
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3771:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3772:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_3772
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3772
.L_lambda_simple_env_end_3772:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3772:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3772
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3772
.L_lambda_simple_params_end_3772:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3772
	jmp .L_lambda_simple_end_3772
.L_lambda_simple_code_3772:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_3772
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3772:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3773:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_3773
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3773
.L_lambda_simple_env_end_3773:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3773:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_3773
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3773
.L_lambda_simple_params_end_3773:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3773
	jmp .L_lambda_simple_end_3773
.L_lambda_simple_code_3773:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_3773
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3773:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47f0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47f4
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_402c:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_402c:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_402c
.L_tc_recycle_frame_done_402c:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47f4

        	.L_if_else_47f4:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47f5
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 1]
.L_applic_TC_402b:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_402b:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_402b
.L_tc_recycle_frame_done_402b:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47f5

        	.L_if_else_47f5:
	push 0
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_402a:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_402a:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_402a
.L_tc_recycle_frame_done_402a:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47f5:

        	.L_if_end_47f4:

        	jmp .L_if_end_47f0

        	.L_if_else_47f0:
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47f1
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47f2
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 1]
.L_applic_TC_4029:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4029:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4029
.L_tc_recycle_frame_done_4029:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47f2

        	.L_if_else_47f2:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47f3
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 1]
.L_applic_TC_4028:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4028:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4028
.L_tc_recycle_frame_done_4028:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47f3

        	.L_if_else_47f3:
	push 0
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_4027:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4027:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4027
.L_tc_recycle_frame_done_4027:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47f3:

        	.L_if_end_47f2:

        	jmp .L_if_end_47f1

        	.L_if_else_47f1:
	mov rax,L_constants + 0

        	.L_if_end_47f1:

        	.L_if_end_47f0:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_3773:	; new closure is in rax
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_3772:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3774:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_3774
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3774
.L_lambda_simple_env_end_3774:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3774:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3774
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3774
.L_lambda_simple_params_end_3774:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3774
	jmp .L_lambda_simple_end_3774
.L_lambda_simple_code_3774:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3774
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3774:
	enter 0, 0
	mov rax, qword [free_var_39]
	push rax
	mov rax, qword [free_var_40]
	push rax
	push 2
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3775:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_3775
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3775
.L_lambda_simple_env_end_3775:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3775:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3775
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3775
.L_lambda_simple_params_end_3775:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3775
	jmp .L_lambda_simple_end_3775
.L_lambda_simple_code_3775:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3775
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3775:
	enter 0, 0
	mov rax, qword [free_var_41]
	push rax
	mov rax, qword [free_var_42]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3776:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_3776
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3776
.L_lambda_simple_env_end_3776:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3776:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3776
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3776
.L_lambda_simple_params_end_3776:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3776
	jmp .L_lambda_simple_end_3776
.L_lambda_simple_code_3776:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3776
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3776:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3777:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_3777
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3777
.L_lambda_simple_env_end_3777:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3777:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3777
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3777
.L_lambda_simple_params_end_3777:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3777
	jmp .L_lambda_simple_end_3777
.L_lambda_simple_code_3777:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_3777
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3777:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_86]
.L_applic_TC_402d:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_402d:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_402d
.L_tc_recycle_frame_done_402d:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_3777:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3778:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_3778
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3778
.L_lambda_simple_env_end_3778:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3778:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3778
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3778
.L_lambda_simple_params_end_3778:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3778
	jmp .L_lambda_simple_end_3778
.L_lambda_simple_code_3778:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3778
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3778:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 6	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3779:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 5
	je .L_lambda_simple_env_end_3779
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3779
.L_lambda_simple_env_end_3779:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3779:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3779
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3779
.L_lambda_simple_params_end_3779:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3779
	jmp .L_lambda_simple_end_3779
.L_lambda_simple_code_3779:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_3779
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3779:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_402e:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_402e:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_402e
.L_tc_recycle_frame_done_402e:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_3779:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 6	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_377a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 5
	je .L_lambda_simple_env_end_377a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_377a
.L_lambda_simple_env_end_377a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_377a:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_377a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_377a
.L_lambda_simple_params_end_377a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_377a
	jmp .L_lambda_simple_end_377a
.L_lambda_simple_code_377a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_377a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_377a:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 7	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_377b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 6
	je .L_lambda_simple_env_end_377b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_377b
.L_lambda_simple_env_end_377b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_377b:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_377b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_377b
.L_lambda_simple_params_end_377b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_377b
	jmp .L_lambda_simple_end_377b
.L_lambda_simple_code_377b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_377b
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_377b:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_86]
.L_applic_TC_402f:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_402f:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_402f
.L_tc_recycle_frame_done_402f:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_377b:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 7	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_377c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 6
	je .L_lambda_simple_env_end_377c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_377c
.L_lambda_simple_env_end_377c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_377c:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_377c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_377c
.L_lambda_simple_params_end_377c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_377c
	jmp .L_lambda_simple_end_377c
.L_lambda_simple_code_377c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_377c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_377c:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 8	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_377d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 7
	je .L_lambda_simple_env_end_377d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_377d
.L_lambda_simple_env_end_377d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_377d:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_377d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_377d
.L_lambda_simple_params_end_377d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_377d
	jmp .L_lambda_simple_end_377d
.L_lambda_simple_code_377d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_377d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_377d:
	enter 0, 0
	mov rax,L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 9	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_377e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 8
	je .L_lambda_simple_env_end_377e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_377e
.L_lambda_simple_env_end_377e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_377e:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_377e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_377e
.L_lambda_simple_params_end_377e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_377e
	jmp .L_lambda_simple_end_377e
.L_lambda_simple_code_377e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_377e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_377e:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 10	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_377f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 9
	je .L_lambda_simple_env_end_377f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_377f
.L_lambda_simple_env_end_377f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_377f:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_377f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_377f
.L_lambda_simple_params_end_377f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_377f
	jmp .L_lambda_simple_end_377f
.L_lambda_simple_code_377f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_377f
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_377f:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0427
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47f6
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_4030:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4030:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4030
.L_tc_recycle_frame_done_4030:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47f6

        	.L_if_else_47f6:
	mov rax,L_constants + 2

        	.L_if_end_47f6:
.L_or_end_0427:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_377f:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	push rax
	mov rdi, 8 * 10
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_0887:

        	cmp rsi, 9

        	je .L_lambda_opt_env_end_0887
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_0887

        	.L_lambda_opt_env_end_0887:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_0887:

        	cmp rsi, 1

        	je .L_lambda_opt_params_end_0887
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_0887

        	.L_lambda_opt_params_end_0887:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0887

        	jmp .L_lambda_opt_end_0887

        	.L_lambda_opt_code_0887:

        	cmp qword [rsp + 8 * 2], 1

        	je .L_lambda_opt_arity_check_exact_0887  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_0887  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_0887:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_1993:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1993
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_1993

        	.L_lambda_opt_stack_shrink_loop_exit_1993:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0887

        	.L_lambda_opt_arity_check_more_0887:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 1]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_1994:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1994
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_1994

        	.L_lambda_opt_stack_shrink_loop_exit_1994:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (1 + 2))]

        	mov rcx, 1 

        	.L_lambda_opt_stack_shrink_loop_1995:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1995
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_1995

        	.L_lambda_opt_stack_shrink_loop_exit_1995:

        	mov qword [rdx], 1 + 1
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_0887:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_4031:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4031:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4031
.L_tc_recycle_frame_done_4031:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0887:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_377e:	; new closure is in rax
.L_applic_TC_4032:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4032:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4032
.L_tc_recycle_frame_done_4032:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_377d:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 8	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3780:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 7
	je .L_lambda_simple_env_end_3780
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3780
.L_lambda_simple_env_end_3780:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3780:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3780
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3780
.L_lambda_simple_params_end_3780:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3780
	jmp .L_lambda_simple_end_3780
.L_lambda_simple_code_3780:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3780
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3780:
	enter 0, 0
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 4]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_102], rax

        	mov rax, sob_void

	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_103], rax

        	mov rax, sob_void

	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_104], rax

        	mov rax, sob_void

	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_105], rax

        	mov rax, sob_void

	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 3]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_106], rax

        	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3780:	; new closure is in rax
.L_applic_TC_4033:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4033:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4033
.L_tc_recycle_frame_done_4033:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_377c:	; new closure is in rax
.L_applic_TC_4034:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4034:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4034
.L_tc_recycle_frame_done_4034:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_377a:	; new closure is in rax
.L_applic_TC_4035:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4035:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4035
.L_tc_recycle_frame_done_4035:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3778:	; new closure is in rax
.L_applic_TC_4036:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4036:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4036
.L_tc_recycle_frame_done_4036:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3776:	; new closure is in rax
.L_applic_TC_4037:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4037:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4037
.L_tc_recycle_frame_done_4037:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3775:	; new closure is in rax
.L_applic_TC_4038:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4038:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4038
.L_tc_recycle_frame_done_4038:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3774:	; new closure is in rax
.L_applic_TC_4039:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4039:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4039
.L_tc_recycle_frame_done_4039:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3771:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3781:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3781
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3781
.L_lambda_simple_env_end_3781:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3781:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3781
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3781
.L_lambda_simple_params_end_3781:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3781
	jmp .L_lambda_simple_end_3781
.L_lambda_simple_code_3781:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3781
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3781:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3782:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_3782
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3782
.L_lambda_simple_env_end_3782:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3782:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3782
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3782
.L_lambda_simple_params_end_3782:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3782
	jmp .L_lambda_simple_end_3782
.L_lambda_simple_code_3782:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_3782
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3782:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_27]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47f7
	mov rax,L_constants + 1

        	jmp .L_if_end_47f7

        	.L_if_else_47f7:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax,L_constants + 128
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_98]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_13]
.L_applic_TC_403a:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_403a:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_403a
.L_tc_recycle_frame_done_403a:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47f7:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_3782:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	push rax
	mov rdi, 8 * 2
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_0888:

        	cmp rsi, 1

        	je .L_lambda_opt_env_end_0888
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_0888

        	.L_lambda_opt_env_end_0888:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_0888:

        	cmp rsi, 1

        	je .L_lambda_opt_params_end_0888
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_0888

        	.L_lambda_opt_params_end_0888:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0888

        	jmp .L_lambda_opt_end_0888

        	.L_lambda_opt_code_0888:

        	cmp qword [rsp + 8 * 2], 1

        	je .L_lambda_opt_arity_check_exact_0888  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_0888  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_0888:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_1996:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1996
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_1996

        	.L_lambda_opt_stack_shrink_loop_exit_1996:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0888

        	.L_lambda_opt_arity_check_more_0888:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 1]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_1997:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1997
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_1997

        	.L_lambda_opt_stack_shrink_loop_exit_1997:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (1 + 2))]

        	mov rcx, 1 

        	.L_lambda_opt_stack_shrink_loop_1998:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1998
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_1998

        	.L_lambda_opt_stack_shrink_loop_exit_1998:

        	mov qword [rdx], 1 + 1
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_0888:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47f8
	mov rax,L_constants + 4
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_403d:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_403d:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_403d
.L_tc_recycle_frame_done_403d:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47f8

        	.L_if_else_47f8:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47fa
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47fb
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_3]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	jmp .L_if_end_47fb

        	.L_if_else_47fb:
	mov rax,L_constants + 2

        	.L_if_end_47fb:

        	jmp .L_if_end_47fa

        	.L_if_else_47fa:
	mov rax,L_constants + 2

        	.L_if_end_47fa:

        	cmp rax, sob_boolean_false

        	je .L_if_else_47f9
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_403c:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_403c:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_403c
.L_tc_recycle_frame_done_403c:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47f9

        	.L_if_else_47f9:
	mov rax,L_constants + 288
	push rax
	mov rax,L_constants + 279
	push rax
	push 2
	mov rax, qword [free_var_38]
.L_applic_TC_403b:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_403b:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_403b
.L_tc_recycle_frame_done_403b:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_47f9:

        	.L_if_end_47f8:
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0888:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3781:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_107], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_108], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_109], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_110], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_111], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_112], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3783:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3783
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3783
.L_lambda_simple_env_end_3783:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3783:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3783
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3783
.L_lambda_simple_params_end_3783:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3783
	jmp .L_lambda_simple_end_3783
.L_lambda_simple_code_3783:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3783
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3783:
	enter 0, 0
	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	push rax
	mov rdi, 8 * 2
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_0889:

        	cmp rsi, 1

        	je .L_lambda_opt_env_end_0889
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_0889

        	.L_lambda_opt_env_end_0889:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_0889:

        	cmp rsi, 1

        	je .L_lambda_opt_params_end_0889
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_0889

        	.L_lambda_opt_params_end_0889:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0889

        	jmp .L_lambda_opt_end_0889

        	.L_lambda_opt_code_0889:

        	cmp qword [rsp + 8 * 2], 0

        	je .L_lambda_opt_arity_check_exact_0889  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_0889  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_0889:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_1999:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_1999
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_1999

        	.L_lambda_opt_stack_shrink_loop_exit_1999:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0889

        	.L_lambda_opt_arity_check_more_0889:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 0]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_199a:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_199a
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_199a

        	.L_lambda_opt_stack_shrink_loop_exit_199a:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (0 + 2))]

        	mov rcx, 0 

        	.L_lambda_opt_stack_shrink_loop_199b:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_199b
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_199b

        	.L_lambda_opt_stack_shrink_loop_exit_199b:

        	mov qword [rdx], 1 + 0
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_0889:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [free_var_24]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [free_var_89]
.L_applic_TC_403e:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_403e:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_403e
.L_tc_recycle_frame_done_403e:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0889:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3783:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3784:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3784
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3784
.L_lambda_simple_env_end_3784:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3784:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3784
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3784
.L_lambda_simple_params_end_3784:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3784
	jmp .L_lambda_simple_end_3784
.L_lambda_simple_code_3784:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3784
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3784:
	enter 0, 0
	mov rax, qword [free_var_102]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_108], rax

        	mov rax, sob_void

	mov rax, qword [free_var_103]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_109], rax

        	mov rax, sob_void

	mov rax, qword [free_var_106]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_110], rax

        	mov rax, sob_void

	mov rax, qword [free_var_104]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_111], rax

        	mov rax, sob_void

	mov rax, qword [free_var_105]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_112], rax

        	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3784:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_113], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_114], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 342
	push rax
	push 1
	mov rax, qword [free_var_24]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax,L_constants + 346
	push rax
	push 1
	mov rax, qword [free_var_24]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_98]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3785:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3785
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3785
.L_lambda_simple_env_end_3785:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3785:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3785
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3785
.L_lambda_simple_params_end_3785:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3785
	jmp .L_lambda_simple_end_3785
.L_lambda_simple_code_3785:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3785
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3785:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3786:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_3786
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3786
.L_lambda_simple_env_end_3786:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3786:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3786
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3786
.L_lambda_simple_params_end_3786:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3786
	jmp .L_lambda_simple_end_3786
.L_lambda_simple_code_3786:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3786
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3786:
	enter 0, 0
	mov rax,L_constants + 344
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax,L_constants + 342
	push rax
	push 3
	mov rax, qword [free_var_109]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47fc
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_24]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_25]
.L_applic_TC_403f:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_403f:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_403f
.L_tc_recycle_frame_done_403f:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47fc

        	.L_if_else_47fc:
	mov rax ,qword[rbp + 8 * (4 + 0)]

        	.L_if_end_47fc:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3786:	; new closure is in rax
	mov qword [free_var_113], rax

        	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3787:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_3787
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3787
.L_lambda_simple_env_end_3787:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3787:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3787
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3787
.L_lambda_simple_params_end_3787:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3787
	jmp .L_lambda_simple_end_3787
.L_lambda_simple_code_3787:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3787
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3787:
	enter 0, 0
	mov rax,L_constants + 348
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax,L_constants + 346
	push rax
	push 3
	mov rax, qword [free_var_109]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47fd
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_24]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_98]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_25]
.L_applic_TC_4040:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4040:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4040
.L_tc_recycle_frame_done_4040:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_47fd

        	.L_if_else_47fd:
	mov rax ,qword[rbp + 8 * (4 + 0)]

        	.L_if_end_47fd:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3787:	; new closure is in rax
	mov qword [free_var_114], rax

        	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3785:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_115], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_116], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_117], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_118], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_119], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3788:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3788
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3788
.L_lambda_simple_env_end_3788:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3788:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3788
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3788
.L_lambda_simple_params_end_3788:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3788
	jmp .L_lambda_simple_end_3788
.L_lambda_simple_code_3788:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3788
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3788:
	enter 0, 0
	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	push rax
	mov rdi, 8 * 2
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_088a:

        	cmp rsi, 1

        	je .L_lambda_opt_env_end_088a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_088a

        	.L_lambda_opt_env_end_088a:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_088a:

        	cmp rsi, 1

        	je .L_lambda_opt_params_end_088a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_088a

        	.L_lambda_opt_params_end_088a:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_088a

        	jmp .L_lambda_opt_end_088a

        	.L_lambda_opt_code_088a:

        	cmp qword [rsp + 8 * 2], 0

        	je .L_lambda_opt_arity_check_exact_088a  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_088a  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_088a:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_199c:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_199c
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_199c

        	.L_lambda_opt_stack_shrink_loop_exit_199c:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_088a

        	.L_lambda_opt_arity_check_more_088a:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 0]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_199d:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_199d
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_199d

        	.L_lambda_opt_stack_shrink_loop_exit_199d:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (0 + 2))]

        	mov rcx, 0 

        	.L_lambda_opt_stack_shrink_loop_199e:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_199e
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_199e

        	.L_lambda_opt_stack_shrink_loop_exit_199e:

        	mov qword [rdx], 1 + 0
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_088a:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3789:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_3789
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3789
.L_lambda_simple_env_end_3789:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3789:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3789
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3789
.L_lambda_simple_params_end_3789:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3789
	jmp .L_lambda_simple_end_3789
.L_lambda_simple_code_3789:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3789
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3789:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_113]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_24]
.L_applic_TC_4041:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4041:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4041
.L_tc_recycle_frame_done_4041:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3789:	; new closure is in rax
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [free_var_89]
.L_applic_TC_4042:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4042:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4042
.L_tc_recycle_frame_done_4042:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_088a:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3788:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_378a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_378a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_378a
.L_lambda_simple_env_end_378a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_378a:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_378a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_378a
.L_lambda_simple_params_end_378a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_378a
	jmp .L_lambda_simple_end_378a
.L_lambda_simple_code_378a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_378a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_378a:
	enter 0, 0
	mov rax, qword [free_var_102]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_115], rax

        	mov rax, sob_void

	mov rax, qword [free_var_103]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_116], rax

        	mov rax, sob_void

	mov rax, qword [free_var_106]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_117], rax

        	mov rax, sob_void

	mov rax, qword [free_var_104]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_118], rax

        	mov rax, sob_void

	mov rax, qword [free_var_105]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_119], rax

        	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_378a:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_120], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_121], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_378b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_378b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_378b
.L_lambda_simple_env_end_378b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_378b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_378b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_378b
.L_lambda_simple_params_end_378b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_378b
	jmp .L_lambda_simple_end_378b
.L_lambda_simple_code_378b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_378b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_378b:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_378c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_378c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_378c
.L_lambda_simple_env_end_378c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_378c:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_378c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_378c
.L_lambda_simple_params_end_378c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_378c
	jmp .L_lambda_simple_end_378c
.L_lambda_simple_code_378c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_378c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_378c:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_123]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_122]
.L_applic_TC_4043:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4043:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4043
.L_tc_recycle_frame_done_4043:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_378c:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_378b:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_378d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_378d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_378d
.L_lambda_simple_env_end_378d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_378d:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_378d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_378d
.L_lambda_simple_params_end_378d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_378d
	jmp .L_lambda_simple_end_378d
.L_lambda_simple_code_378d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_378d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_378d:
	enter 0, 0
	mov rax, qword [free_var_113]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_120], rax

        	mov rax, sob_void

	mov rax, qword [free_var_114]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_121], rax

        	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_378d:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_124], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_125], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_126], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_127], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_128], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_129], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_130], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_131], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_132], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 0
	mov qword [free_var_133], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_378e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_378e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_378e
.L_lambda_simple_env_end_378e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_378e:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_378e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_378e
.L_lambda_simple_params_end_378e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_378e
	jmp .L_lambda_simple_end_378e
.L_lambda_simple_code_378e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_378e
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_378e:
	enter 0, 0
	mov rax,L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_378f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_378f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_378f
.L_lambda_simple_env_end_378f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_378f:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_378f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_378f
.L_lambda_simple_params_end_378f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_378f
	jmp .L_lambda_simple_end_378f
.L_lambda_simple_code_378f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_378f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_378f:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3790:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_3790
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3790
.L_lambda_simple_env_end_3790:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3790:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3790
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3790
.L_lambda_simple_params_end_3790:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3790
	jmp .L_lambda_simple_end_3790
.L_lambda_simple_code_3790:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 5
	je .L_lambda_simple_arity_check_ok_3790
	push qword [rsp + 8 * 2]
	push 5
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3790:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47fe
	mov rax ,qword[rbp + 8 * (4 + 4)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	jmp .L_if_end_47fe

        	.L_if_else_47fe:
	mov rax,L_constants + 2

        	.L_if_end_47fe:
	cmp rax, sob_boolean_false
	jne .L_or_end_0428
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_47ff
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 3)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0429
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 3)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4800
	mov rax ,qword[rbp + 8 * (4 + 4)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 3)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax,L_constants + 128
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 5
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_4044:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4044:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4044
.L_tc_recycle_frame_done_4044:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_4800

        	.L_if_else_4800:
	mov rax,L_constants + 2

        	.L_if_end_4800:
.L_or_end_0429:

        	jmp .L_if_end_47ff

        	.L_if_else_47ff:
	mov rax,L_constants + 2

        	.L_if_end_47ff:
.L_or_end_0428:
	leave
	ret 8 * (2 + 5)
.L_lambda_simple_end_3790:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3791:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_3791
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3791
.L_lambda_simple_env_end_3791:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3791:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3791
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3791
.L_lambda_simple_params_end_3791:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3791
	jmp .L_lambda_simple_end_3791
.L_lambda_simple_code_3791:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_3791
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3791:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3792:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_3792
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3792
.L_lambda_simple_env_end_3792:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3792:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_3792
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3792
.L_lambda_simple_params_end_3792:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3792
	jmp .L_lambda_simple_end_3792
.L_lambda_simple_code_3792:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_3792
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3792:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_103]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4801
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 1]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	mov rax,L_constants + 32
	push rax
	push 5
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_4046:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4046:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4046
.L_tc_recycle_frame_done_4046:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_4801

        	.L_if_else_4801:
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 1]
	push rax
	mov rax,L_constants + 32
	push rax
	push 5
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_4045:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4045:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4045
.L_tc_recycle_frame_done_4045:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_4801:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_3792:	; new closure is in rax
.L_applic_TC_4047:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4047:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4047
.L_tc_recycle_frame_done_4047:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_3791:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3793:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_3793
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3793
.L_lambda_simple_env_end_3793:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3793:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3793
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3793
.L_lambda_simple_params_end_3793:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3793
	jmp .L_lambda_simple_end_3793
.L_lambda_simple_code_3793:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3793
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3793:
	enter 0, 0
	mov rax,L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3794:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_3794
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3794
.L_lambda_simple_env_end_3794:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3794:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3794
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3794
.L_lambda_simple_params_end_3794:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3794
	jmp .L_lambda_simple_end_3794
.L_lambda_simple_code_3794:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3794
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3794:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3795:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_3795
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3795
.L_lambda_simple_env_end_3795:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3795:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3795
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3795
.L_lambda_simple_params_end_3795:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3795
	jmp .L_lambda_simple_end_3795
.L_lambda_simple_code_3795:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_3795
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3795:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_042a
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4802
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_4048:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4048:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4048
.L_tc_recycle_frame_done_4048:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_4802

        	.L_if_else_4802:
	mov rax,L_constants + 2

        	.L_if_end_4802:
.L_or_end_042a:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_3795:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	push rax
	mov rdi, 8 * 5
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_088b:

        	cmp rsi, 4

        	je .L_lambda_opt_env_end_088b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_088b

        	.L_lambda_opt_env_end_088b:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_088b:

        	cmp rsi, 1

        	je .L_lambda_opt_params_end_088b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_088b

        	.L_lambda_opt_params_end_088b:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_088b

        	jmp .L_lambda_opt_end_088b

        	.L_lambda_opt_code_088b:

        	cmp qword [rsp + 8 * 2], 1

        	je .L_lambda_opt_arity_check_exact_088b  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_088b  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_088b:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_199f:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_199f
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_199f

        	.L_lambda_opt_stack_shrink_loop_exit_199f:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_088b

        	.L_lambda_opt_arity_check_more_088b:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 1]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_19a0:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_19a0
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_19a0

        	.L_lambda_opt_stack_shrink_loop_exit_19a0:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (1 + 2))]

        	mov rcx, 1 

        	.L_lambda_opt_stack_shrink_loop_19a1:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_19a1
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_19a1

        	.L_lambda_opt_stack_shrink_loop_exit_19a1:

        	mov qword [rdx], 1 + 1
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_088b:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_4049:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4049:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4049
.L_tc_recycle_frame_done_4049:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_088b:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3794:	; new closure is in rax
.L_applic_TC_404a:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_404a:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_404a
.L_tc_recycle_frame_done_404a:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3793:	; new closure is in rax
.L_applic_TC_404b:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_404b:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_404b
.L_tc_recycle_frame_done_404b:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_378f:	; new closure is in rax
.L_applic_TC_404c:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_404c:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_404c
.L_tc_recycle_frame_done_404c:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_378e:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3796:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3796
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3796
.L_lambda_simple_env_end_3796:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3796:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3796
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3796
.L_lambda_simple_params_end_3796:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3796
	jmp .L_lambda_simple_end_3796
.L_lambda_simple_code_3796:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3796
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3796:
	enter 0, 0
	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_108]
	push rax
	push 2
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_124], rax

        	mov rax, sob_void

	mov rax, qword [free_var_117]
	push rax
	mov rax, qword [free_var_115]
	push rax
	push 2
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_129], rax

        	mov rax, sob_void

	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_111]
	push rax
	push 2
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_128], rax

        	mov rax, sob_void

	mov rax, qword [free_var_117]
	push rax
	mov rax, qword [free_var_118]
	push rax
	push 2
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_133], rax

        	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3796:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3797:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_3797
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3797
.L_lambda_simple_env_end_3797:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3797:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_3797
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3797
.L_lambda_simple_params_end_3797:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3797
	jmp .L_lambda_simple_end_3797
.L_lambda_simple_code_3797:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_3797
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3797:
	enter 0, 0
	mov rax,L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3798:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_3798
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3798
.L_lambda_simple_env_end_3798:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3798:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_3798
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3798
.L_lambda_simple_params_end_3798:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3798
	jmp .L_lambda_simple_end_3798
.L_lambda_simple_code_3798:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_3798
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3798:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_3799:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_3799
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_3799
.L_lambda_simple_env_end_3799:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_3799:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_3799
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_3799
.L_lambda_simple_params_end_3799:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_3799
	jmp .L_lambda_simple_end_3799
.L_lambda_simple_code_3799:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 5
	je .L_lambda_simple_arity_check_ok_3799
	push qword [rsp + 8 * 2]
	push 5
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_3799:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_042b
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 3)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_042b
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4803
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 3)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4804
	mov rax ,qword[rbp + 8 * (4 + 4)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 3)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax,L_constants + 128
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 5
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_404d:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_404d:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_404d
.L_tc_recycle_frame_done_404d:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_4804

        	.L_if_else_4804:
	mov rax,L_constants + 2

        	.L_if_end_4804:

        	jmp .L_if_end_4803

        	.L_if_else_4803:
	mov rax,L_constants + 2

        	.L_if_end_4803:
.L_or_end_042b:
	leave
	ret 8 * (2 + 5)
.L_lambda_simple_end_3799:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_379a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_379a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_379a
.L_lambda_simple_env_end_379a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_379a:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_379a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_379a
.L_lambda_simple_params_end_379a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_379a
	jmp .L_lambda_simple_end_379a
.L_lambda_simple_code_379a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_379a
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_379a:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_379b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_379b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_379b
.L_lambda_simple_env_end_379b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_379b:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_379b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_379b
.L_lambda_simple_params_end_379b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_379b
	jmp .L_lambda_simple_end_379b
.L_lambda_simple_code_379b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_379b
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_379b:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_103]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4805
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 1]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	mov rax,L_constants + 32
	push rax
	push 5
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_404f:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_404f:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_404f
.L_tc_recycle_frame_done_404f:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_4805

        	.L_if_else_4805:
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 1]
	push rax
	mov rax,L_constants + 32
	push rax
	push 5
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_404e:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_404e:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_404e
.L_tc_recycle_frame_done_404e:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_4805:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_379b:	; new closure is in rax
.L_applic_TC_4050:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4050:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4050
.L_tc_recycle_frame_done_4050:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_379a:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_379c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_379c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_379c
.L_lambda_simple_env_end_379c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_379c:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_379c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_379c
.L_lambda_simple_params_end_379c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_379c
	jmp .L_lambda_simple_end_379c
.L_lambda_simple_code_379c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_379c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_379c:
	enter 0, 0
	mov rax,L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_379d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_379d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_379d
.L_lambda_simple_env_end_379d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_379d:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_379d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_379d
.L_lambda_simple_params_end_379d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_379d
	jmp .L_lambda_simple_end_379d
.L_lambda_simple_code_379d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_379d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_379d:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_379e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_379e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_379e
.L_lambda_simple_env_end_379e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_379e:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_379e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_379e
.L_lambda_simple_params_end_379e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_379e
	jmp .L_lambda_simple_end_379e
.L_lambda_simple_code_379e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_379e
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_379e:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_042c
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4806
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_4051:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4051:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4051
.L_tc_recycle_frame_done_4051:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_4806

        	.L_if_else_4806:
	mov rax,L_constants + 2

        	.L_if_end_4806:
.L_or_end_042c:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_379e:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	push rax
	mov rdi, 8 * 5
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_088c:

        	cmp rsi, 4

        	je .L_lambda_opt_env_end_088c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_088c

        	.L_lambda_opt_env_end_088c:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_088c:

        	cmp rsi, 1

        	je .L_lambda_opt_params_end_088c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_088c

        	.L_lambda_opt_params_end_088c:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_088c

        	jmp .L_lambda_opt_end_088c

        	.L_lambda_opt_code_088c:

        	cmp qword [rsp + 8 * 2], 1

        	je .L_lambda_opt_arity_check_exact_088c  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_088c  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_088c:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_19a2:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_19a2
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_19a2

        	.L_lambda_opt_stack_shrink_loop_exit_19a2:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_088c

        	.L_lambda_opt_arity_check_more_088c:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 1]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_19a3:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_19a3
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_19a3

        	.L_lambda_opt_stack_shrink_loop_exit_19a3:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (1 + 2))]

        	mov rcx, 1 

        	.L_lambda_opt_stack_shrink_loop_19a4:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_19a4
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_19a4

        	.L_lambda_opt_stack_shrink_loop_exit_19a4:

        	mov qword [rdx], 1 + 1
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_088c:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_4052:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4052:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4052
.L_tc_recycle_frame_done_4052:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_088c:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_379d:	; new closure is in rax
.L_applic_TC_4053:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4053:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4053
.L_tc_recycle_frame_done_4053:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_379c:	; new closure is in rax
.L_applic_TC_4054:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4054:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4054
.L_tc_recycle_frame_done_4054:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_3798:	; new closure is in rax
.L_applic_TC_4055:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4055:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4055
.L_tc_recycle_frame_done_4055:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_3797:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_379f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_379f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_379f
.L_lambda_simple_env_end_379f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_379f:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_379f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_379f
.L_lambda_simple_params_end_379f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_379f
	jmp .L_lambda_simple_end_379f
.L_lambda_simple_code_379f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_379f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_379f:
	enter 0, 0
	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_108]
	push rax
	push 2
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_125], rax

        	mov rax, sob_void

	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_108]
	push rax
	push 2
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_130], rax

        	mov rax, sob_void

	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_111]
	push rax
	push 2
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_127], rax

        	mov rax, sob_void

	mov rax, qword [free_var_117]
	push rax
	mov rax, qword [free_var_118]
	push rax
	push 2
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_132], rax

        	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_379f:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37a0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_37a0
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37a0
.L_lambda_simple_env_end_37a0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37a0:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_37a0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37a0
.L_lambda_simple_params_end_37a0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37a0
	jmp .L_lambda_simple_end_37a0
.L_lambda_simple_code_37a0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37a0
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37a0:
	enter 0, 0
	mov rax,L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37a1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_37a1
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37a1
.L_lambda_simple_env_end_37a1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37a1:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_37a1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37a1
.L_lambda_simple_params_end_37a1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37a1
	jmp .L_lambda_simple_end_37a1
.L_lambda_simple_code_37a1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37a1
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37a1:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37a2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_37a2
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37a2
.L_lambda_simple_env_end_37a2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37a2:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_37a2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37a2
.L_lambda_simple_params_end_37a2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37a2
	jmp .L_lambda_simple_end_37a2
.L_lambda_simple_code_37a2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 4
	je .L_lambda_simple_arity_check_ok_37a2
	push qword [rsp + 8 * 2]
	push 4
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37a2:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 3)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_042d
	mov rax ,qword[rbp + 8 * (4 + 3)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4807
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4808
	mov rax ,qword[rbp + 8 * (4 + 3)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax,L_constants + 128
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 4
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_4056:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4056:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4056
.L_tc_recycle_frame_done_4056:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_4808

        	.L_if_else_4808:
	mov rax,L_constants + 2

        	.L_if_end_4808:

        	jmp .L_if_end_4807

        	.L_if_else_4807:
	mov rax,L_constants + 2

        	.L_if_end_4807:
.L_or_end_042d:
	leave
	ret 8 * (2 + 4)
.L_lambda_simple_end_37a2:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37a3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_37a3
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37a3
.L_lambda_simple_env_end_37a3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37a3:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_37a3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37a3
.L_lambda_simple_params_end_37a3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37a3
	jmp .L_lambda_simple_end_37a3
.L_lambda_simple_code_37a3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_37a3
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37a3:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37a4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_37a4
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37a4
.L_lambda_simple_env_end_37a4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37a4:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_37a4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37a4
.L_lambda_simple_params_end_37a4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37a4
	jmp .L_lambda_simple_end_37a4
.L_lambda_simple_code_37a4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_37a4
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37a4:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4809
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 1]
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	mov rax,L_constants + 32
	push rax
	push 4
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_4057:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4057:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4057
.L_tc_recycle_frame_done_4057:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_4809

        	.L_if_else_4809:
	mov rax,L_constants + 2

        	.L_if_end_4809:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_37a4:	; new closure is in rax
.L_applic_TC_4058:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4058:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4058
.L_tc_recycle_frame_done_4058:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_37a3:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37a5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_37a5
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37a5
.L_lambda_simple_env_end_37a5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37a5:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_37a5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37a5
.L_lambda_simple_params_end_37a5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37a5
	jmp .L_lambda_simple_end_37a5
.L_lambda_simple_code_37a5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37a5
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37a5:
	enter 0, 0
	mov rax,L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37a6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_37a6
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37a6
.L_lambda_simple_env_end_37a6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37a6:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_37a6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37a6
.L_lambda_simple_params_end_37a6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37a6
	jmp .L_lambda_simple_end_37a6
.L_lambda_simple_code_37a6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37a6
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37a6:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37a7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_37a7
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37a7
.L_lambda_simple_env_end_37a7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37a7:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_37a7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37a7
.L_lambda_simple_params_end_37a7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37a7
	jmp .L_lambda_simple_end_37a7
.L_lambda_simple_code_37a7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_37a7
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37a7:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_042e
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_480a
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_4059:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4059:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4059
.L_tc_recycle_frame_done_4059:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_480a

        	.L_if_else_480a:
	mov rax,L_constants + 2

        	.L_if_end_480a:
.L_or_end_042e:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_37a7:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	push rax
	mov rdi, 8 * 5
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_088d:

        	cmp rsi, 4

        	je .L_lambda_opt_env_end_088d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_088d

        	.L_lambda_opt_env_end_088d:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_088d:

        	cmp rsi, 1

        	je .L_lambda_opt_params_end_088d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_088d

        	.L_lambda_opt_params_end_088d:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_088d

        	jmp .L_lambda_opt_end_088d

        	.L_lambda_opt_code_088d:

        	cmp qword [rsp + 8 * 2], 1

        	je .L_lambda_opt_arity_check_exact_088d  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_088d  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_088d:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_19a5:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_19a5
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_19a5

        	.L_lambda_opt_stack_shrink_loop_exit_19a5:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_088d

        	.L_lambda_opt_arity_check_more_088d:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 1]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_19a6:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_19a6
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_19a6

        	.L_lambda_opt_stack_shrink_loop_exit_19a6:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (1 + 2))]

        	mov rcx, 1 

        	.L_lambda_opt_stack_shrink_loop_19a7:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_19a7
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_19a7

        	.L_lambda_opt_stack_shrink_loop_exit_19a7:

        	mov qword [rdx], 1 + 1
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_088d:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_405a:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_405a:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_405a
.L_tc_recycle_frame_done_405a:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_088d:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37a6:	; new closure is in rax
.L_applic_TC_405b:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_405b:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_405b
.L_tc_recycle_frame_done_405b:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37a5:	; new closure is in rax
.L_applic_TC_405c:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_405c:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_405c
.L_tc_recycle_frame_done_405c:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37a1:	; new closure is in rax
.L_applic_TC_405d:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_405d:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_405d
.L_tc_recycle_frame_done_405d:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37a0:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37a8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_37a8
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37a8
.L_lambda_simple_env_end_37a8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37a8:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_37a8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37a8
.L_lambda_simple_params_end_37a8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37a8
	jmp .L_lambda_simple_end_37a8
.L_lambda_simple_code_37a8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37a8
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37a8:
	enter 0, 0
	mov rax, qword [free_var_110]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_126], rax

        	mov rax, sob_void

	mov rax, qword [free_var_117]
	push rax
	push 1
	mov rax ,qword[rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_131], rax

        	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37a8:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37a9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_37a9
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37a9
.L_lambda_simple_env_end_37a9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37a9:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_37a9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37a9
.L_lambda_simple_params_end_37a9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37a9
	jmp .L_lambda_simple_end_37a9
.L_lambda_simple_code_37a9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37a9
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37a9:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_480b
	mov rax,L_constants + 32

        	jmp .L_if_end_480b

        	.L_if_else_480b:
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_134]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax,L_constants + 128
	push rax
	push 2
	mov rax, qword [free_var_97]
.L_applic_TC_405e:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_405e:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_405e
.L_tc_recycle_frame_done_405e:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_480b:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37a9:	; new closure is in rax
	mov qword [free_var_134], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37aa:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_37aa
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37aa
.L_lambda_simple_env_end_37aa:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37aa:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_37aa
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37aa
.L_lambda_simple_params_end_37aa:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37aa
	jmp .L_lambda_simple_end_37aa
.L_lambda_simple_code_37aa:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37aa
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37aa:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_042f
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_480c
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_84]
.L_applic_TC_405f:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_405f:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_405f
.L_tc_recycle_frame_done_405f:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_480c

        	.L_if_else_480c:
	mov rax,L_constants + 2

        	.L_if_end_480c:
.L_or_end_042f:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37aa:	; new closure is in rax
	mov qword [free_var_84], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword [free_var_51]
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37ab:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_37ab
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37ab
.L_lambda_simple_env_end_37ab:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37ab:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_37ab
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37ab
.L_lambda_simple_params_end_37ab:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37ab
	jmp .L_lambda_simple_end_37ab
.L_lambda_simple_code_37ab:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37ab
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37ab:
	enter 0, 0
	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	push rax
	mov rdi, 8 * 2
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_088e:

        	cmp rsi, 1

        	je .L_lambda_opt_env_end_088e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_088e

        	.L_lambda_opt_env_end_088e:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_088e:

        	cmp rsi, 1

        	je .L_lambda_opt_params_end_088e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_088e

        	.L_lambda_opt_params_end_088e:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_088e

        	jmp .L_lambda_opt_end_088e

        	.L_lambda_opt_code_088e:

        	cmp qword [rsp + 8 * 2], 1

        	je .L_lambda_opt_arity_check_exact_088e  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_088e  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_088e:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_19a8:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_19a8
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_19a8

        	.L_lambda_opt_stack_shrink_loop_exit_19a8:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_088e

        	.L_lambda_opt_arity_check_more_088e:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 1]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_19a9:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_19a9
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_19a9

        	.L_lambda_opt_stack_shrink_loop_exit_19a9:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (1 + 2))]

        	mov rcx, 1 

        	.L_lambda_opt_stack_shrink_loop_19aa:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_19aa
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_19aa

        	.L_lambda_opt_stack_shrink_loop_exit_19aa:

        	mov qword [rdx], 1 + 1
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_088e:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_480d
	mov rax,L_constants + 0

        	jmp .L_if_end_480d

        	.L_if_else_480d:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_480f
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	jmp .L_if_end_480f

        	.L_if_else_480f:
	mov rax,L_constants + 2

        	.L_if_end_480f:

        	cmp rax, sob_boolean_false

        	je .L_if_else_480e
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	jmp .L_if_end_480e

        	.L_if_else_480e:
	mov rax,L_constants + 379
	push rax
	mov rax,L_constants + 370
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	.L_if_end_480e:

        	.L_if_end_480d:
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37ac:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_37ac
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37ac
.L_lambda_simple_env_end_37ac:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37ac:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_37ac
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37ac
.L_lambda_simple_params_end_37ac:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37ac
	jmp .L_lambda_simple_end_37ac
.L_lambda_simple_code_37ac:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37ac
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37ac:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_4060:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4060:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4060
.L_tc_recycle_frame_done_4060:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37ac:	; new closure is in rax
.L_applic_TC_4061:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4061:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4061
.L_tc_recycle_frame_done_4061:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_088e:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37ab:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_51], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword [free_var_52]
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37ad:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_37ad
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37ad
.L_lambda_simple_env_end_37ad:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37ad:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_37ad
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37ad
.L_lambda_simple_params_end_37ad:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37ad
	jmp .L_lambda_simple_end_37ad
.L_lambda_simple_code_37ad:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37ad
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37ad:
	enter 0, 0
	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	push rax
	mov rdi, 8 * 2
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_088f:

        	cmp rsi, 1

        	je .L_lambda_opt_env_end_088f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_088f

        	.L_lambda_opt_env_end_088f:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_088f:

        	cmp rsi, 1

        	je .L_lambda_opt_params_end_088f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_088f

        	.L_lambda_opt_params_end_088f:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_088f

        	jmp .L_lambda_opt_end_088f

        	.L_lambda_opt_code_088f:

        	cmp qword [rsp + 8 * 2], 1

        	je .L_lambda_opt_arity_check_exact_088f  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_088f  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_088f:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_19ab:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_19ab
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_19ab

        	.L_lambda_opt_stack_shrink_loop_exit_19ab:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_088f

        	.L_lambda_opt_arity_check_more_088f:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 1]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_19ac:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_19ac
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_19ac

        	.L_lambda_opt_stack_shrink_loop_exit_19ac:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (1 + 2))]

        	mov rcx, 1 

        	.L_lambda_opt_stack_shrink_loop_19ad:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_19ad
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_19ad

        	.L_lambda_opt_stack_shrink_loop_exit_19ad:

        	mov qword [rdx], 1 + 1
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_088f:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4810
	mov rax,L_constants + 4

        	jmp .L_if_end_4810

        	.L_if_else_4810:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4812
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	jmp .L_if_end_4812

        	.L_if_else_4812:
	mov rax,L_constants + 2

        	.L_if_end_4812:

        	cmp rax, sob_boolean_false

        	je .L_if_else_4811
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	jmp .L_if_end_4811

        	.L_if_else_4811:
	mov rax,L_constants + 460
	push rax
	mov rax,L_constants + 451
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	.L_if_end_4811:

        	.L_if_end_4810:
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37ae:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_37ae
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37ae
.L_lambda_simple_env_end_37ae:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37ae:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_37ae
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37ae
.L_lambda_simple_params_end_37ae:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37ae
	jmp .L_lambda_simple_end_37ae
.L_lambda_simple_code_37ae:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37ae
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37ae:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 1]

                          	mov rax, qword[rax + 8 * 0]
.L_applic_TC_4062:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4062:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4062
.L_tc_recycle_frame_done_4062:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37ae:	; new closure is in rax
.L_applic_TC_4063:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4063:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4063
.L_tc_recycle_frame_done_4063:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_088f:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37ad:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_52], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37af:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_37af
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37af
.L_lambda_simple_env_end_37af:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37af:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_37af
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37af
.L_lambda_simple_params_end_37af:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37af
	jmp .L_lambda_simple_end_37af
.L_lambda_simple_code_37af:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37af
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37af:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37b0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_37b0
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37b0
.L_lambda_simple_env_end_37b0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37b0:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_37b0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37b0
.L_lambda_simple_params_end_37b0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37b0
	jmp .L_lambda_simple_end_37b0
.L_lambda_simple_code_37b0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_37b0
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37b0:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4813
	mov rax,L_constants + 0
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_51]
.L_applic_TC_4065:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4065:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4065
.L_tc_recycle_frame_done_4065:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_4813

        	.L_if_else_4813:
	mov rax,L_constants + 128
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37b1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_37b1
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37b1
.L_lambda_simple_env_end_37b1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37b1:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_37b1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37b1
.L_lambda_simple_params_end_37b1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37b1
	jmp .L_lambda_simple_end_37b1
.L_lambda_simple_code_37b1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37b1
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37b1:
	enter 0, 0
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 1]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [free_var_49]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

	mov rax ,qword[rbp + 8 * (4 + 0)]
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37b1:	; new closure is in rax
.L_applic_TC_4064:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4064:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4064
.L_tc_recycle_frame_done_4064:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_4813:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_37b0:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37b2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_37b2
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37b2
.L_lambda_simple_env_end_37b2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37b2:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_37b2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37b2
.L_lambda_simple_params_end_37b2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37b2
	jmp .L_lambda_simple_end_37b2
.L_lambda_simple_code_37b2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37b2
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37b2:
	enter 0, 0
	mov rax,L_constants + 32
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_4066:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4066:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4066
.L_tc_recycle_frame_done_4066:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37b2:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37af:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_135], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37b3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_37b3
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37b3
.L_lambda_simple_env_end_37b3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37b3:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_37b3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37b3
.L_lambda_simple_params_end_37b3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37b3
	jmp .L_lambda_simple_end_37b3
.L_lambda_simple_code_37b3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37b3
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37b3:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37b4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_37b4
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37b4
.L_lambda_simple_env_end_37b4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37b4:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_37b4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37b4
.L_lambda_simple_params_end_37b4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37b4
	jmp .L_lambda_simple_end_37b4
.L_lambda_simple_code_37b4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_37b4
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37b4:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4814
	mov rax,L_constants + 4
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_52]
.L_applic_TC_4068:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4068:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4068
.L_tc_recycle_frame_done_4068:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_4814

        	.L_if_else_4814:
	mov rax,L_constants + 128
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37b5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_37b5
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37b5
.L_lambda_simple_env_end_37b5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37b5:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_37b5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37b5
.L_lambda_simple_params_end_37b5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37b5
	jmp .L_lambda_simple_end_37b5
.L_lambda_simple_code_37b5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37b5
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37b5:
	enter 0, 0
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 1]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [free_var_50]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

	mov rax ,qword[rbp + 8 * (4 + 0)]
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37b5:	; new closure is in rax
.L_applic_TC_4067:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4067:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4067
.L_tc_recycle_frame_done_4067:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_4814:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_37b4:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37b6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_37b6
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37b6
.L_lambda_simple_env_end_37b6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37b6:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_37b6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37b6
.L_lambda_simple_params_end_37b6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37b6
	jmp .L_lambda_simple_end_37b6
.L_lambda_simple_code_37b6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37b6
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37b6:
	enter 0, 0
	mov rax,L_constants + 32
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_4069:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4069:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4069
.L_tc_recycle_frame_done_4069:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37b6:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37b3:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_122], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)
	call malloc
	push rax
	mov rdi, 8 * 0
	call malloc
	push rax
	mov rdi, 8 * 1
	call malloc
	mov rdi, ENV
	xor rsi, rsi
	xor rdx, rdx
	inc rdx
	.L_lambda_opt_env_loop_0890:

        	cmp rsi, 0

        	je .L_lambda_opt_env_end_0890
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	add rdx, 1
	add rsi, 1
	jmp .L_lambda_opt_env_loop_0890

        	.L_lambda_opt_env_end_0890:
	pop rbx
	xor rsi, rsi
	.L_lambda_opt_params_loop_0890:

        	cmp rsi, 0

        	je .L_lambda_opt_params_end_0890
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	add rsi, 1
	jmp .L_lambda_opt_params_loop_0890

        	.L_lambda_opt_params_end_0890:
	mov qword [rax], rbx	; ext_env = new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0890

        	jmp .L_lambda_opt_end_0890

        	.L_lambda_opt_code_0890:

        	cmp qword [rsp + 8 * 2], 0

        	je .L_lambda_opt_arity_check_exact_0890  ;same num_of_args

        	jg .L_lambda_opt_arity_check_more_0890  ;greater num_of_args
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt ;less than num_of_args
.L_lambda_opt_arity_check_exact_0890:
	sub rsp, 8 * 1
	lea rdi, [rdi + (8 * 2)]
	mov rdi, rsp 
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	mov rax, qword [rdi + 8]
	mov rcx, rax
	add rax, 1
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	.L_lambda_opt_stack_shrink_loop_19ae:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_19ae
	sub rcx, 1
	lea rax, [rax + (8 * 2)]
	mov rax, qword [rdi + 8]
	mov qword [rdi], rax
	lea rdi, [rdi + 8]
	jmp .L_lambda_opt_stack_shrink_loop_19ae

        	.L_lambda_opt_stack_shrink_loop_exit_19ae:
	mov qword [rdi], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0890

        	.L_lambda_opt_arity_check_more_0890:
	mov rsi, qword [rsp + (8 * 2)]
	lea rcx, [rsi - 0]
	mov r8, sob_nil
	lea rsi, [rsp + (8 * rsi) + (8 * 2)]
	mov rdx, rsi
	.L_lambda_opt_stack_shrink_loop_19af:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_19af
	mov rdi, 1 + (8 * 2)
	call malloc
	mov byte [rax], T_pair
	mov rbx, qword [rsi]
	mov SOB_PAIR_CAR(rax), rbx
	mov SOB_PAIR_CDR(rax), r8
	add rsi, -8
	sub rcx, 1
	mov r8, rax
	jmp .L_lambda_opt_stack_shrink_loop_19af

        	.L_lambda_opt_stack_shrink_loop_exit_19af:
	mov qword [rdx], r8
	sub rdx, 8 * 1
	lea rsi, [rsp + (8 * (0 + 2))]

        	mov rcx, 0 

        	.L_lambda_opt_stack_shrink_loop_19b0:
	cmp rcx, 0
	je .L_lambda_opt_stack_shrink_loop_exit_19b0
	mov rax, qword [rsi]
	mov qword [rdx], rax
	lea rsi, [rsi - 8]
	add rdx, -8
	add rcx, -1
	jmp .L_lambda_opt_stack_shrink_loop_19b0

        	.L_lambda_opt_stack_shrink_loop_exit_19b0:

        	mov qword [rdx], 1 + 0
	add rsi, -8
	add rdx, -8
	mov rax, qword [rsi]
	mov qword [rdx], rax
	add rdx, -8
	lea rsi, [rsi - 8]
	mov rax, qword [rsi]
	mov qword [rdx], rax
	mov rsp, rdx
	.L_lambda_opt_stack_adjusted_0890:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_135]
.L_applic_TC_406a:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_406a:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_406a
.L_tc_recycle_frame_done_406a:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0890:	; new closure is in rax
	mov qword [free_var_136], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37b7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_37b7
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37b7
.L_lambda_simple_env_end_37b7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37b7:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_37b7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37b7
.L_lambda_simple_params_end_37b7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37b7
	jmp .L_lambda_simple_end_37b7
.L_lambda_simple_code_37b7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37b7
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37b7:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37b8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_37b8
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37b8
.L_lambda_simple_env_end_37b8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37b8:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_37b8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37b8
.L_lambda_simple_params_end_37b8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37b8
	jmp .L_lambda_simple_end_37b8
.L_lambda_simple_code_37b8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_37b8
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37b8:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4815
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	mov rax,L_constants + 128
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
.L_applic_TC_406b:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_406b:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_406b
.L_tc_recycle_frame_done_406b:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_4815

        	.L_if_else_4815:
	mov rax,L_constants + 1

        	.L_if_end_4815:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_37b8:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37b9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_37b9
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37b9
.L_lambda_simple_env_end_37b9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37b9:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_37b9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37b9
.L_lambda_simple_params_end_37b9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37b9
	jmp .L_lambda_simple_end_37b9
.L_lambda_simple_code_37b9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37b9
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37b9:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax,L_constants + 32
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_406c:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_406c:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_406c
.L_tc_recycle_frame_done_406c:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37b9:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37b7:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_123], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37ba:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_37ba
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37ba
.L_lambda_simple_env_end_37ba:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37ba:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_37ba
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37ba
.L_lambda_simple_params_end_37ba:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37ba
	jmp .L_lambda_simple_end_37ba
.L_lambda_simple_code_37ba:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37ba
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37ba:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37bb:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_37bb
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37bb
.L_lambda_simple_env_end_37bb:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37bb:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_37bb
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37bb
.L_lambda_simple_params_end_37bb:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37bb
	jmp .L_lambda_simple_end_37bb
.L_lambda_simple_code_37bb:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_37bb
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37bb:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4816
	mov rax ,qword[rbp + 8 * (4 + 2)]
	push rax
	mov rax,L_constants + 128
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_48]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
.L_applic_TC_406d:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_406d:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_406d
.L_tc_recycle_frame_done_406d:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_4816

        	.L_if_else_4816:
	mov rax,L_constants + 1

        	.L_if_end_4816:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_37bb:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37bc:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_37bc
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37bc
.L_lambda_simple_env_end_37bc:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37bc:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_37bc
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37bc
.L_lambda_simple_params_end_37bc:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37bc
	jmp .L_lambda_simple_end_37bc
.L_lambda_simple_code_37bc:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37bc
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37bc:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_19]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax,L_constants + 32
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_406e:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_406e:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_406e
.L_tc_recycle_frame_done_406e:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37bc:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37ba:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_137], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37bd:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_37bd
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37bd
.L_lambda_simple_env_end_37bd:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37bd:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_37bd
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37bd
.L_lambda_simple_params_end_37bd:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37bd
	jmp .L_lambda_simple_end_37bd
.L_lambda_simple_code_37bd:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37bd
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37bd:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 0
	mov rax, qword [free_var_26]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_44]
.L_applic_TC_406f:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_406f:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_406f
.L_tc_recycle_frame_done_406f:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37bd:	; new closure is in rax
	mov qword [free_var_138], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37be:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_37be
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37be
.L_lambda_simple_env_end_37be:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37be:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_37be
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37be
.L_lambda_simple_params_end_37be:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37be
	jmp .L_lambda_simple_end_37be
.L_lambda_simple_code_37be:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37be
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37be:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax,L_constants + 32
	push rax
	push 2
	mov rax, qword [free_var_102]
.L_applic_TC_4070:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4070:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4070
.L_tc_recycle_frame_done_4070:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37be:	; new closure is in rax
	mov qword [free_var_139], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37bf:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_37bf
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37bf
.L_lambda_simple_env_end_37bf:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37bf:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_37bf
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37bf
.L_lambda_simple_params_end_37bf:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37bf
	jmp .L_lambda_simple_end_37bf
.L_lambda_simple_code_37bf:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37bf
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37bf:
	enter 0, 0
	mov rax,L_constants + 32
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_102]
.L_applic_TC_4071:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4071:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4071
.L_tc_recycle_frame_done_4071:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37bf:	; new closure is in rax
	mov qword [free_var_140], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37c0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_37c0
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37c0
.L_lambda_simple_env_end_37c0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37c0:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_37c0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37c0
.L_lambda_simple_params_end_37c0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37c0
	jmp .L_lambda_simple_end_37c0
.L_lambda_simple_code_37c0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37c0
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37c0:
	enter 0, 0
	mov rax,L_constants + 512
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_44]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_27]
.L_applic_TC_4072:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4072:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4072
.L_tc_recycle_frame_done_4072:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37c0:	; new closure is in rax
	mov qword [free_var_141], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37c1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_37c1
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37c1
.L_lambda_simple_env_end_37c1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37c1:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_37c1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37c1
.L_lambda_simple_params_end_37c1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37c1
	jmp .L_lambda_simple_end_37c1
.L_lambda_simple_code_37c1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37c1
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37c1:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_141]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_86]
.L_applic_TC_4073:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4073:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4073
.L_tc_recycle_frame_done_4073:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37c1:	; new closure is in rax
	mov qword [free_var_142], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37c2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_37c2
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37c2
.L_lambda_simple_env_end_37c2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37c2:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_37c2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37c2
.L_lambda_simple_params_end_37c2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37c2
	jmp .L_lambda_simple_end_37c2
.L_lambda_simple_code_37c2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37c2
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37c2:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_140]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4817
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_98]
.L_applic_TC_4074:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4074:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4074
.L_tc_recycle_frame_done_4074:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_4817

        	.L_if_else_4817:
	mov rax ,qword[rbp + 8 * (4 + 0)]

        	.L_if_end_4817:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37c2:	; new closure is in rax
	mov qword [free_var_143], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37c3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_37c3
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37c3
.L_lambda_simple_env_end_37c3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37c3:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_37c3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37c3
.L_lambda_simple_params_end_37c3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37c3
	jmp .L_lambda_simple_end_37c3
.L_lambda_simple_code_37c3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_37c3
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37c3:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4820
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	jmp .L_if_end_4820

        	.L_if_else_4820:
	mov rax,L_constants + 2

        	.L_if_end_4820:

        	cmp rax, sob_boolean_false

        	je .L_if_else_4818
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_144]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_481f
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_144]
.L_applic_TC_4078:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4078:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4078
.L_tc_recycle_frame_done_4078:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_481f

        	.L_if_else_481f:
	mov rax,L_constants + 2

        	.L_if_end_481f:

        	jmp .L_if_end_4818

        	.L_if_else_4818:
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_6]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_481d
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_6]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_481e
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_19]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_19]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	jmp .L_if_end_481e

        	.L_if_else_481e:
	mov rax,L_constants + 2

        	.L_if_end_481e:

        	jmp .L_if_end_481d

        	.L_if_else_481d:
	mov rax,L_constants + 2

        	.L_if_end_481d:

        	cmp rax, sob_boolean_false

        	je .L_if_else_4819
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_137]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_137]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_144]
.L_applic_TC_4077:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4077:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4077
.L_tc_recycle_frame_done_4077:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_4819

        	.L_if_else_4819:
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_4]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_481b
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_4]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_481c
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	jmp .L_if_end_481c

        	.L_if_else_481c:
	mov rax,L_constants + 2

        	.L_if_end_481c:

        	jmp .L_if_end_481b

        	.L_if_else_481b:
	mov rax,L_constants + 2

        	.L_if_end_481b:

        	cmp rax, sob_boolean_false

        	je .L_if_else_481a
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_126]
.L_applic_TC_4076:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4076:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4076
.L_tc_recycle_frame_done_4076:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_481a

        	.L_if_else_481a:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_55]
.L_applic_TC_4075:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4075:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4075
.L_tc_recycle_frame_done_4075:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_481a:

        	.L_if_end_4819:

        	.L_if_end_4818:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_37c3:	; new closure is in rax
	mov qword [free_var_144], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37c4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_37c4
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37c4
.L_lambda_simple_env_end_37c4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37c4:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_37c4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37c4
.L_lambda_simple_params_end_37c4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37c4
	jmp .L_lambda_simple_end_37c4
.L_lambda_simple_code_37c4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_37c4
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37c4:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4821
	mov rax,L_constants + 2

        	jmp .L_if_end_4821

        	.L_if_else_4821:
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_55]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4822
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
.L_applic_TC_407a:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_407a:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_407a
.L_tc_recycle_frame_done_407a:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_4822

        	.L_if_else_4822:
	mov rax ,qword[rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_145]
.L_applic_TC_4079:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_4079:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_4079
.L_tc_recycle_frame_done_4079:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	.L_if_end_4822:

        	.L_if_end_4821:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_37c4:	; new closure is in rax
	mov qword [free_var_145], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 23
	push rax
	mov rax,L_constants + 23
	push rax
	mov rax,L_constants + 23
	push rax
	mov rax,L_constants + 23
	push rax
	push 4
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37c5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_37c5
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37c5
.L_lambda_simple_env_end_37c5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37c5:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_37c5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37c5
.L_lambda_simple_params_end_37c5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37c5
	jmp .L_lambda_simple_end_37c5
.L_lambda_simple_code_37c5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 4
	je .L_lambda_simple_arity_check_ok_37c5
	push qword [rsp + 8 * 2]
	push 4
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37c5:
	enter 0, 0
	mov rdi, 8
	call malloc
	mov rbx, PARAM(0)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 0)], rax

         	mov rax, sob_void

	mov rdi, 8
	call malloc
	mov rbx, PARAM(1)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 1)], rax

         	mov rax, sob_void

	mov rdi, 8
	call malloc
	mov rbx, PARAM(2)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 2)], rax

         	mov rax, sob_void

	mov rdi, 8
	call malloc
	mov rbx, PARAM(3)
	mov qword [rax], rbx
	mov qword [rbp + 8 * (4 + 3)], rax

         	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 4	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37c6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_37c6
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37c6
.L_lambda_simple_env_end_37c6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37c6:	; copy params
	cmp rsi, 4
	je .L_lambda_simple_params_end_37c6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37c6
.L_lambda_simple_params_end_37c6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37c6
	jmp .L_lambda_simple_end_37c6
.L_lambda_simple_code_37c6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_37c6
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37c6:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_27]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0430
	mov rax,L_constants + 543
	push rax
	mov rax,L_constants + 128
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_98]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 1]
	mov rax, qword [rax]
.L_applic_TC_407b:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_407b:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_407b
.L_tc_recycle_frame_done_407b:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
.L_or_end_0430:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_37c6:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 4	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37c7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_37c7
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37c7
.L_lambda_simple_env_end_37c7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37c7:	; copy params
	cmp rsi, 4
	je .L_lambda_simple_params_end_37c7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37c7
.L_lambda_simple_params_end_37c7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37c7
	jmp .L_lambda_simple_end_37c7
.L_lambda_simple_code_37c7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_37c7
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37c7:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_139]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4823
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax,L_constants + 128
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_98]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 2]
	mov rax, qword [rax]
.L_applic_TC_407c:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_407c:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_407c
.L_tc_recycle_frame_done_407c:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_4823

        	.L_if_else_4823:
	mov rax,L_constants + 2

        	.L_if_end_4823:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_37c7:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 1)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 4	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37c8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_37c8
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37c8
.L_lambda_simple_env_end_37c8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37c8:	; copy params
	cmp rsi, 4
	je .L_lambda_simple_params_end_37c8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37c8
.L_lambda_simple_params_end_37c8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37c8
	jmp .L_lambda_simple_end_37c8
.L_lambda_simple_code_37c8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_37c8
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37c8:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_27]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0431
	mov rax,L_constants + 591
	push rax
	mov rax,L_constants + 566
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_99]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax,L_constants + 128
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_98]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 5
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 3]
	mov rax, qword [rax]
.L_applic_TC_407d:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_407d:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_407d
.L_tc_recycle_frame_done_407d:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx
.L_or_end_0431:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_37c8:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 2)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 4	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_37c9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_37c9
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_37c9
.L_lambda_simple_env_end_37c9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_37c9:	; copy params
	cmp rsi, 4
	je .L_lambda_simple_params_end_37c9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_37c9
.L_lambda_simple_params_end_37c9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_37c9
	jmp .L_lambda_simple_end_37c9
.L_lambda_simple_code_37c9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 5
	je .L_lambda_simple_arity_check_ok_37c9
	push qword [rsp + 8 * 2]
	push 5
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_37c9:
	enter 0, 0
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_139]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false

        	je .L_if_else_4824
	mov rax,L_constants + 128
	push rax
	mov rax ,qword[rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_98]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [rbp + 8 * 2]

                          	mov rax, qword[rax + 8 * 0]

                          	mov rax, qword[rax + 8 * 0]
	mov rax, qword [rax]
.L_applic_TC_407e:
	cmp byte [rax], T_closure
	jne L_code_ptr_error
	mov rbx, SOB_CLOSURE_ENV(rax)
	push rbx
	push qword [rbp + 8]
	push qword [rbp]
	mov rcx, [rbp + 3 * 8]
	mov rdx, [rsp + 3 * 8]
	lea rsi, [rdx + 4]
	lea r9, [rsi - 1]
	lea rdi, [rcx + 3]
	xor r8, r8
.L_tc_recycle_frame_loop_407e:
	mov r8, [rsp + (r9 * 8)]
	mov [rbp + (rdi * 8)], r8
	dec r9
	xor r8, r8
	dec rdi
	dec rsi
	cmp rsi, 0
	jne .L_tc_recycle_frame_loop_407e
.L_tc_recycle_frame_done_407e:
;this pop rbp in sot to the right place
	mov r9, rcx
	lea r9, [8 * (r9 + 4)]
	add rsp, r9
	pop rbp
	mov rcx, qword [rbp]
	mov rbx, SOB_CLOSURE_CODE(rax)
	jmp rbx

        	jmp .L_if_end_4824

        	.L_if_else_4824:
	mov rax,L_constants + 2

        	.L_if_end_4824:
	leave
	ret 8 * (2 + 5)
.L_lambda_simple_end_37c9:	; new closure is in rax
	push rax
	mov rax ,qword[rbp + 8 * (4 + 3)]
	pop qword [rax]
	mov rax, sob_void

	mov rax ,qword[rbp + 8 * (4 + 0)]
	mov rax, qword [rax]
	leave
	ret 8 * (2 + 4)
.L_lambda_simple_end_37c5:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_141], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax,L_constants + 600
	push rax
	push 1
	mov rax, qword [free_var_141]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax) 
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

        mov rdi, fmt_memory_usage
        mov rsi, qword [top_of_memory]
        sub rsi, memory
        mov rax, 0
	ENTER
        call printf
	LEAVE
	leave
	ret

L_error_non_closure:
        mov rdi, qword [stderr]
        mov rsi, fmt_non_closure
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -2
        call exit

L_error_improper_list:
	mov rdi, qword [stderr]
	mov rsi, fmt_error_improper_list
	mov rax, 0
	ENTER
	call fprintf
	LEAVE
	mov rax, -7
	call exit

L_error_incorrect_arity_simple:
        mov rdi, qword [stderr]
        mov rsi, fmt_incorrect_arity_simple
        jmp L_error_incorrect_arity_common
L_error_incorrect_arity_opt:
        mov rdi, qword [stderr]
        mov rsi, fmt_incorrect_arity_opt
L_error_incorrect_arity_common:
        pop rdx
        pop rcx
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -6
        call exit

section .data
fmt_incorrect_arity_simple:
        db `!!! Expected %ld arguments, but given %ld\n\0`
fmt_incorrect_arity_opt:
        db `!!! Expected at least %ld arguments, but given %ld\n\0`
fmt_memory_usage:
        db `\n\n!!! Used %ld bytes of dynamically-allocated memory\n\n\0`
fmt_non_closure:
        db `!!! Attempting to apply a non-closure!\n\0`
fmt_error_improper_list:
	db `!!! The argument is not a proper list!\n\0`

section .bss
memory:
	resb gbytes(1)

section .data
top_of_memory:
        dq memory

section .text
malloc:
        mov rax, qword [top_of_memory]
        add qword [top_of_memory], rdi
        ret
        
print_sexpr_if_not_void:
	cmp rdi, sob_void
	jne print_sexpr
	ret

section .data
fmt_void:
	db `#<void>\0`
fmt_nil:
	db `()\0`
fmt_boolean_false:
	db `#f\0`
fmt_boolean_true:
	db `#t\0`
fmt_char_backslash:
	db `#\\\\\0`
fmt_char_dquote:
	db `#\\"\0`
fmt_char_simple:
	db `#\\%c\0`
fmt_char_null:
	db `#\\nul\0`
fmt_char_bell:
	db `#\\bell\0`
fmt_char_backspace:
	db `#\\backspace\0`
fmt_char_tab:
	db `#\\tab\0`
fmt_char_newline:
	db `#\\newline\0`
fmt_char_formfeed:
	db `#\\page\0`
fmt_char_return:
	db `#\\return\0`
fmt_char_escape:
	db `#\\esc\0`
fmt_char_space:
	db `#\\space\0`
fmt_char_hex:
	db `#\\x%02X\0`
fmt_closure:
	db `#<closure at 0x%08X env=0x%08X code=0x%08X>\0`
fmt_lparen:
	db `(\0`
fmt_dotted_pair:
	db ` . \0`
fmt_rparen:
	db `)\0`
fmt_space:
	db ` \0`
fmt_empty_vector:
	db `#()\0`
fmt_vector:
	db `#(\0`
fmt_real:
	db `%f\0`
fmt_fraction:
	db `%ld/%ld\0`
fmt_zero:
	db `0\0`
fmt_int:
	db `%ld\0`
fmt_unknown_sexpr_error:
	db `\n\n!!! Error: Unknown type of sexpr (0x%02X) `
	db `at address 0x%08X\n\n\0`
fmt_dquote:
	db `\"\0`
fmt_string_char:
        db `%c\0`
fmt_string_char_7:
        db `\\a\0`
fmt_string_char_8:
        db `\\b\0`
fmt_string_char_9:
        db `\\t\0`
fmt_string_char_10:
        db `\\n\0`
fmt_string_char_11:
        db `\\v\0`
fmt_string_char_12:
        db `\\f\0`
fmt_string_char_13:
        db `\\r\0`
fmt_string_char_34:
        db `\\"\0`
fmt_string_char_92:
        db `\\\\\0`
fmt_string_char_hex:
        db `\\x%X;\0`

section .text

print_sexpr:
	ENTER
	mov al, byte [rdi]
	cmp al, T_void
	je .Lvoid
	cmp al, T_nil
	je .Lnil
	cmp al, T_boolean_false
	je .Lboolean_false
	cmp al, T_boolean_true
	je .Lboolean_true
	cmp al, T_char
	je .Lchar
	cmp al, T_symbol
	je .Lsymbol
	cmp al, T_pair
	je .Lpair
	cmp al, T_vector
	je .Lvector
	cmp al, T_closure
	je .Lclosure
	cmp al, T_real
	je .Lreal
	cmp al, T_rational
	je .Lrational
	cmp al, T_string
	je .Lstring

	jmp .Lunknown_sexpr_type

.Lvoid:
	mov rdi, fmt_void
	jmp .Lemit

.Lnil:
	mov rdi, fmt_nil
	jmp .Lemit

.Lboolean_false:
	mov rdi, fmt_boolean_false
	jmp .Lemit

.Lboolean_true:
	mov rdi, fmt_boolean_true
	jmp .Lemit

.Lchar:
	mov al, byte [rdi + 1]
	cmp al, ' '
	jle .Lchar_whitespace
	cmp al, 92 		; backslash
	je .Lchar_backslash
	cmp al, '"'
	je .Lchar_dquote
	and rax, 255
	mov rdi, fmt_char_simple
	mov rsi, rax
	jmp .Lemit

.Lchar_whitespace:
	cmp al, 0
	je .Lchar_null
	cmp al, 7
	je .Lchar_bell
	cmp al, 8
	je .Lchar_backspace
	cmp al, 9
	je .Lchar_tab
	cmp al, 10
	je .Lchar_newline
	cmp al, 12
	je .Lchar_formfeed
	cmp al, 13
	je .Lchar_return
	cmp al, 27
	je .Lchar_escape
	and rax, 255
	cmp al, ' '
	je .Lchar_space
	mov rdi, fmt_char_hex
	mov rsi, rax
	jmp .Lemit	

.Lchar_backslash:
	mov rdi, fmt_char_backslash
	jmp .Lemit

.Lchar_dquote:
	mov rdi, fmt_char_dquote
	jmp .Lemit

.Lchar_null:
	mov rdi, fmt_char_null
	jmp .Lemit

.Lchar_bell:
	mov rdi, fmt_char_bell
	jmp .Lemit

.Lchar_backspace:
	mov rdi, fmt_char_backspace
	jmp .Lemit

.Lchar_tab:
	mov rdi, fmt_char_tab
	jmp .Lemit

.Lchar_newline:
	mov rdi, fmt_char_newline
	jmp .Lemit

.Lchar_formfeed:
	mov rdi, fmt_char_formfeed
	jmp .Lemit

.Lchar_return:
	mov rdi, fmt_char_return
	jmp .Lemit

.Lchar_escape:
	mov rdi, fmt_char_escape
	jmp .Lemit

.Lchar_space:
	mov rdi, fmt_char_space
	jmp .Lemit

.Lclosure:
	mov rsi, qword rdi
	mov rdi, fmt_closure
	mov rdx, SOB_CLOSURE_ENV(rsi)
	mov rcx, SOB_CLOSURE_CODE(rsi)
	jmp .Lemit

.Lsymbol:
	mov rdi, qword [rdi + 1] ; sob_string
	mov rsi, 1		 ; size = 1 byte
	mov rdx, qword [rdi + 1] ; length
	lea rdi, [rdi + 1 + 8]	 ; actual characters
	mov rcx, qword [stdout]	 ; FILE *
	call fwrite
	jmp .Lend
	
.Lpair:
	push rdi
	mov rdi, fmt_lparen
	mov rax, 0
        ENTER
	call printf
        LEAVE
	mov rdi, qword [rsp] 	; pair
	mov rdi, SOB_PAIR_CAR(rdi)
	call print_sexpr
	pop rdi 		; pair
	mov rdi, SOB_PAIR_CDR(rdi)
.Lcdr:
	mov al, byte [rdi]
	cmp al, T_nil
	je .Lcdr_nil
	cmp al, T_pair
	je .Lcdr_pair
	push rdi
	mov rdi, fmt_dotted_pair
	mov rax, 0
	ENTER
	call printf
	LEAVE
	pop rdi
	call print_sexpr
	mov rdi, fmt_rparen
	mov rax, 0
	ENTER
	call printf
	LEAVE
	LEAVE
	ret

.Lcdr_nil:
	mov rdi, fmt_rparen
	mov rax, 0
	ENTER
	call printf
	LEAVE
	LEAVE
	ret

.Lcdr_pair:
	push rdi
	mov rdi, fmt_space
	mov rax, 0
	ENTER
	call printf
	LEAVE
	mov rdi, qword [rsp]
	mov rdi, SOB_PAIR_CAR(rdi)
	call print_sexpr
	pop rdi
	mov rdi, SOB_PAIR_CDR(rdi)
	jmp .Lcdr

.Lvector:
	mov rax, qword [rdi + 1] ; length
	cmp rax, 0
	je .Lvector_empty
	push rdi
	mov rdi, fmt_vector
	mov rax, 0
	ENTER
	call printf
	LEAVE
	mov rdi, qword [rsp]
	push qword [rdi + 1]
	push 1
	mov rdi, qword [rdi + 1 + 8] ; v[0]
	call print_sexpr
.Lvector_loop:
	; [rsp] index
	; [rsp + 8*1] limit
	; [rsp + 8*2] vector
	mov rax, qword [rsp]
	cmp rax, qword [rsp + 8*1]
	je .Lvector_end
	mov rdi, fmt_space
	mov rax, 0
	ENTER
	call printf
	LEAVE
	mov rax, qword [rsp]
	mov rbx, qword [rsp + 8*2]
	mov rdi, qword [rbx + 1 + 8 + 8 * rax] ; v[i]
	call print_sexpr
	inc qword [rsp]
	jmp .Lvector_loop

.Lvector_end:
	add rsp, 8*3
	mov rdi, fmt_rparen
	jmp .Lemit	

.Lvector_empty:
	mov rdi, fmt_empty_vector
	jmp .Lemit

.Lreal:
	push qword [rdi + 1]
	movsd xmm0, qword [rsp]
	add rsp, 8*1
	mov rdi, fmt_real
	mov rax, 1
	ENTER
	call printf
	LEAVE
	jmp .Lend

.Lrational:
	mov rsi, qword [rdi + 1]
	mov rdx, qword [rdi + 1 + 8]
	cmp rsi, 0
	je .Lrat_zero
	cmp rdx, 1
	je .Lrat_int
	mov rdi, fmt_fraction
	jmp .Lemit

.Lrat_zero:
	mov rdi, fmt_zero
	jmp .Lemit

.Lrat_int:
	mov rdi, fmt_int
	jmp .Lemit

.Lstring:
	lea rax, [rdi + 1 + 8]
	push rax
	push qword [rdi + 1]
	mov rdi, fmt_dquote
	mov rax, 0
	ENTER
	call printf
	LEAVE
.Lstring_loop:
	; qword [rsp]: limit
	; qword [rsp + 8*1]: char *
	cmp qword [rsp], 0
	je .Lstring_end
	mov rax, qword [rsp + 8*1]
	mov al, byte [rax]
	and rax, 255
	cmp al, 7
        je .Lstring_char_7
        cmp al, 8
        je .Lstring_char_8
        cmp al, 9
        je .Lstring_char_9
        cmp al, 10
        je .Lstring_char_10
        cmp al, 11
        je .Lstring_char_11
        cmp al, 12
        je .Lstring_char_12
        cmp al, 13
        je .Lstring_char_13
        cmp al, 34
        je .Lstring_char_34
        cmp al, 92              ; \
        je .Lstring_char_92
        cmp al, ' '
        jl .Lstring_char_hex
        mov rdi, fmt_string_char
        mov rsi, rax
.Lstring_char_emit:
        mov rax, 0
        ENTER
        call printf
        LEAVE
        dec qword [rsp]
        inc qword [rsp + 8*1]
        jmp .Lstring_loop

.Lstring_char_7:
        mov rdi, fmt_string_char_7
        jmp .Lstring_char_emit

.Lstring_char_8:
        mov rdi, fmt_string_char_8
        jmp .Lstring_char_emit
        
.Lstring_char_9:
        mov rdi, fmt_string_char_9
        jmp .Lstring_char_emit

.Lstring_char_10:
        mov rdi, fmt_string_char_10
        jmp .Lstring_char_emit

.Lstring_char_11:
        mov rdi, fmt_string_char_11
        jmp .Lstring_char_emit

.Lstring_char_12:
        mov rdi, fmt_string_char_12
        jmp .Lstring_char_emit

.Lstring_char_13:
        mov rdi, fmt_string_char_13
        jmp .Lstring_char_emit

.Lstring_char_34:
        mov rdi, fmt_string_char_34
        jmp .Lstring_char_emit

.Lstring_char_92:
        mov rdi, fmt_string_char_92
        jmp .Lstring_char_emit

.Lstring_char_hex:
        mov rdi, fmt_string_char_hex
        mov rsi, rax
        jmp .Lstring_char_emit        

.Lstring_end:
	add rsp, 8 * 2
	mov rdi, fmt_dquote
	jmp .Lemit

.Lunknown_sexpr_type:
	mov rsi, fmt_unknown_sexpr_error
	and rax, 255
	mov rdx, rax
	mov rcx, rdi
	mov rdi, qword [stderr]
	mov rax, 0
	ENTER
	call fprintf
	LEAVE
	mov rax, -1
	call exit

.Lemit:
	mov rax, 0
	ENTER
	call printf
	LEAVE
	jmp .Lend

.Lend:
	LEAVE
	ret

;;; rdi: address of free variable
;;; rsi: address of code-pointer
bind_primitive:
        ENTER
        push rdi
        mov rdi, (1 + 8 + 8)
        call malloc
        pop rdi
        mov byte [rax], T_closure
        mov SOB_CLOSURE_ENV(rax), 0 ; dummy, lexical environment
        mov SOB_CLOSURE_CODE(rax), rsi ; code pointer
        mov qword [rdi], rax
        LEAVE
        ret

;;; PLEASE IMPLEMENT THIS PROCEDURE
L_code_ptr_bin_apply:
        enter 0, 0
        ;finding the list's length
        xor rcx, rcx ;0
        mov rax, qword [rbp + 8 * 5] ;rax = address of scmpair list
        assert_pair(rax)
        mov rbx ,SOB_PAIR_CAR(rax) ;node val
        my_loop1:
                cmp rax, sob_nil ;if nill
                je my_loop_end1 ;jmp end
                inc rcx 
                push rbx ;insrting val to stack
                assert_pair(rax)
                mov rax, SOB_PAIR_CDR(rax) ;next node
                mov rbx ,SOB_PAIR_CAR(rax) ;next val
                jmp my_loop1
        my_loop_end1:
        
        

        ;make values in the opposite order:
        ;1.pushing all argument one more time in the right order
        mov rbx, rcx ;count-up
        mov rcx, 0 
        mov rdx, rsp ;marking the begining of the second pushing
        my_loop2:
                cmp rcx, rbx ; if rcx = n
                je my_loop_end2 ;then: jump to the end
                mov rax, qword [rdx + 8 * rcx] ;else: rax = next arg in correct order
                push rax
                inc rcx
                jmp my_loop2
        my_loop_end2:
        
        ;2.overwriting element above by element below but in correct order
        lea rdx, [8 * (rbx + 6)] ;nubmer of *bytes* we need to skip
        mov rsi, qword [rbp + 8 * 0] ; save old rbp
        mov rdi, qword [rbp + 8 * 1] ; save return address
        mov r8, qword [rbp + 8 * 4]  ; save function to apply
        mov rcx, 0
        my_loop3:
                cmp rcx, rbx ;if rcx = n
                je my_loop_end3 ;then: jump to the end
                mov rax, qword [rsp + 8 * 0] ;else: get next arg in correct order
                lea r9, [rsp + rdx] ;address of arg that needs to be over written
                mov [r9], rax ;over writing arg in false order by arg with correct order
                add rsp, 8 ;pop arg we used
                inc rcx 
                xor rax, rax
                jmp my_loop3
        my_loop_end3:
        
        cmp rcx, 6
        jg seven_or_more
        lea rsp, [rsp + 8 * rcx];pop all 1st time pushed args
        neg rbx 
        add rbx, 6      ;sub 6 from num_of_args
        lea rsp, [rsp + 8 * rbx] ; pop rest of old frame 
        jmp continu
        seven_or_more:
        lea rsp, [rsp + 8 * 6] ; pop rest of 1st time pushed args
        continu:
        push rcx ;push number of arguments
        push SOB_CLOSURE_ENV(r8) ; push lex-env
        push rdi ; push old ret-add
        mov rbp, rsi ;rbp = old-rbp
        jmp SOB_CLOSURE_CODE(r8) ; fun to apply
	
L_code_ptr_is_null:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_nil
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_pair:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_pair
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_is_void:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_void
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_char:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_char
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_string:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_string
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_symbol:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_symbol
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_vector:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_vector
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_closure:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_closure
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_real:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_real
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_rational:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_rational
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_boolean:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        mov bl, byte [rax]
        and bl, T_boolean
        je .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_is_number:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        mov bl, byte [rax]
        and bl, T_number
        je .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_is_collection:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        mov bl, byte [rax]
        and bl, T_collection
        je .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_cons:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rdi, (1 + 8 + 8)
        call malloc
        mov byte [rax], T_pair
        mov rbx, PARAM(0)
        mov SOB_PAIR_CAR(rax), rbx
        mov rbx, PARAM(1)
        mov SOB_PAIR_CDR(rax), rbx
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_display_sexpr:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rdi, PARAM(0)
        call print_sexpr
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_write_char:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_char(rax)
        mov al, SOB_CHAR_VALUE(rax)
        and rax, 255
        mov rdi, fmt_char
        mov rsi, rax
        mov rax, 0
	ENTER
        call printf
	LEAVE
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_car:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_pair(rax)
        mov rax, SOB_PAIR_CAR(rax)
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_cdr:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_pair(rax)
        mov rax, SOB_PAIR_CDR(rax)
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_string_length:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_string(rax)
        mov rdi, SOB_STRING_LENGTH(rax)
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_vector_length:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_vector(rax)
        mov rdi, SOB_VECTOR_LENGTH(rax)
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_real_to_integer:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rbx, PARAM(0)
        assert_real(rbx)
        movsd xmm0, qword [rbx + 1]
        cvttsd2si rdi, xmm0
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_exit:
        ENTER
        cmp COUNT, 0
        jne L_error_arg_count_0
        mov rax, 0
        call exit

L_code_ptr_integer_to_real:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_integer(rax)
        push qword [rax + 1]
        cvtsi2sd xmm0, qword [rsp]
        call make_real
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_rational_to_real:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_rational(rax)
        push qword [rax + 1]
        cvtsi2sd xmm0, qword [rsp]
        push qword [rax + 1 + 8]
        cvtsi2sd xmm1, qword [rsp]
        divsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_char_to_integer:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_char(rax)
        mov al, byte [rax + 1]
        and rax, 255
        mov rdi, rax
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_integer_to_char:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_integer(rax)
        mov rbx, qword [rax + 1]
        cmp rbx, 0
        jle L_error_integer_range
        cmp rbx, 256
        jge L_error_integer_range
        mov rdi, (1 + 1)
        call malloc
        mov byte [rax], T_char
        mov byte [rax + 1], bl
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_trng:
        ENTER
        cmp COUNT, 0
        jne L_error_arg_count_0
        rdrand rdi
        shr rdi, 1
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(0)

L_code_ptr_is_zero:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_rational
        je .L_rational
        cmp byte [rax], T_real
        je .L_real
        jmp L_error_incorrect_type
.L_rational:
        cmp qword [rax + 1], 0
        je .L_zero
        jmp .L_not_zero
.L_real:
        pxor xmm0, xmm0
        push qword [rax + 1]
        movsd xmm1, qword [rsp]
        ucomisd xmm0, xmm1
        je .L_zero
.L_not_zero:
        mov rax, sob_boolean_false
        jmp .L_end
.L_zero:
        mov rax, sob_boolean_true
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_integer:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_rational
        jne .L_false
        cmp qword [rax + 1 + 8], 1
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_raw_bin_add_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rbx, PARAM(0)
        assert_real(rbx)
        mov rcx, PARAM(1)
        assert_real(rcx)
        movsd xmm0, qword [rbx + 1]
        movsd xmm1, qword [rcx + 1]
        addsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_sub_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rbx, PARAM(0)
        assert_real(rbx)
        mov rcx, PARAM(1)
        assert_real(rcx)
        movsd xmm0, qword [rbx + 1]
        movsd xmm1, qword [rcx + 1]
        subsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_mul_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rbx, PARAM(0)
        assert_real(rbx)
        mov rcx, PARAM(1)
        assert_real(rcx)
        movsd xmm0, qword [rbx + 1]
        movsd xmm1, qword [rcx + 1]
        mulsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_div_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rbx, PARAM(0)
        assert_real(rbx)
        mov rcx, PARAM(1)
        assert_real(rcx)
        movsd xmm0, qword [rbx + 1]
        movsd xmm1, qword [rcx + 1]
        pxor xmm2, xmm2
        ucomisd xmm1, xmm2
        je L_error_division_by_zero
        divsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_add_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov r8, PARAM(0)
        assert_rational(r8)
        mov r9, PARAM(1)
        assert_rational(r9)
        mov rax, qword [r8 + 1] ; num1
        mov rbx, qword [r9 + 1 + 8] ; den 2
        cqo
        imul rbx
        mov rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1]     ; num2
        cqo
        imul rbx
        add rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1 + 8] ; den2
        cqo
        imul rbx
        mov rdi, rax
        call normalize_rational
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_sub_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov r8, PARAM(0)
        assert_rational(r8)
        mov r9, PARAM(1)
        assert_rational(r9)
        mov rax, qword [r8 + 1] ; num1
        mov rbx, qword [r9 + 1 + 8] ; den 2
        cqo
        imul rbx
        mov rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1]     ; num2
        cqo
        imul rbx
        sub rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1 + 8] ; den2
        cqo
        imul rbx
        mov rdi, rax
        call normalize_rational
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_mul_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov r8, PARAM(0)
        assert_rational(r8)
        mov r9, PARAM(1)
        assert_rational(r9)
        mov rax, qword [r8 + 1] ; num1
        mov rbx, qword [r9 + 1] ; num2
        cqo
        imul rbx
        mov rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1 + 8] ; den2
        cqo
        imul rbx
        mov rdi, rax
        call normalize_rational
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_raw_bin_div_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov r8, PARAM(0)
        assert_rational(r8)
        mov r9, PARAM(1)
        assert_rational(r9)
        cmp qword [r9 + 1], 0
        je L_error_division_by_zero
        mov rax, qword [r8 + 1] ; num1
        mov rbx, qword [r9 + 1 + 8] ; den 2
        cqo
        imul rbx
        mov rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1] ; num2
        cqo
        imul rbx
        mov rdi, rax
        call normalize_rational
        LEAVE
        ret AND_KILL_FRAME(2)
        
normalize_rational:
        push rsi
        push rdi
        call gcd
        mov rbx, rax
        pop rax
        cqo
        idiv rbx
        mov r8, rax
        pop rax
        cqo
        idiv rbx
        mov r9, rax
        mov rdi, (1 + 8 + 8)
        call malloc
        mov byte [rax], T_rational
        mov qword [rax + 1], r9
        mov qword [rax + 1 + 8], r8
        ret

iabs:
        mov rax, rdi
        cmp rax, 0
        jl .Lneg
        ret
.Lneg:
        neg rax
        ret

gcd:
        call iabs
        mov rbx, rax
        mov rdi, rsi
        call iabs
        cmp rax, 0
        jne .L0
        xchg rax, rbx
.L0:
        cmp rbx, 0
        je .L1
        cqo
        div rbx
        mov rax, rdx
        xchg rax, rbx
        jmp .L0
.L1:
        ret

L_code_ptr_error:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_symbol(rsi)
        mov rsi, PARAM(1)
        assert_string(rsi)
        mov rdi, fmt_scheme_error_part_1
        mov rax, 0
	ENTER
        call printf
	LEAVE
        mov rdi, PARAM(0)
        call print_sexpr
        mov rdi, fmt_scheme_error_part_2
        mov rax, 0
	ENTER
        call printf
	LEAVE
        mov rax, PARAM(1)       ; sob_string
        mov rsi, 1              ; size = 1 byte
        mov rdx, qword [rax + 1] ; length
        lea rdi, [rax + 1 + 8]   ; actual characters
        mov rcx, qword [stdout]  ; FILE*
        call fwrite
        mov rdi, fmt_scheme_error_part_3
        mov rax, 0
	ENTER
        call printf
	LEAVE
        mov rax, -9
        call exit

L_code_ptr_raw_less_than_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_real(rsi)
        mov rdi, PARAM(1)
        assert_real(rdi)
        movsd xmm0, qword [rsi + 1]
        movsd xmm1, qword [rdi + 1]
        comisd xmm0, xmm1
        jae .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_raw_less_than_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_rational(rsi)
        mov rdi, PARAM(1)
        assert_rational(rdi)
        mov rax, qword [rsi + 1] ; num1
        cqo
        imul qword [rdi + 1 + 8] ; den2
        mov rcx, rax
        mov rax, qword [rsi + 1 + 8] ; den1
        cqo
        imul qword [rdi + 1]          ; num2
        sub rcx, rax
        jge .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_equal_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_real(rsi)
        mov rdi, PARAM(1)
        assert_real(rdi)
        movsd xmm0, qword [rsi + 1]
        movsd xmm1, qword [rdi + 1]
        comisd xmm0, xmm1
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_raw_equal_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_rational(rsi)
        mov rdi, PARAM(1)
        assert_rational(rdi)
        mov rax, qword [rsi + 1] ; num1
        cqo
        imul qword [rdi + 1 + 8] ; den2
        mov rcx, rax
        mov rax, qword [rdi + 1 + 8] ; den1
        cqo
        imul qword [rdi + 1]          ; num2
        sub rcx, rax
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_quotient:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_integer(rsi)
        mov rdi, PARAM(1)
        assert_integer(rdi)
        mov rax, qword [rsi + 1]
        mov rbx, qword [rdi + 1]
        cmp rbx, 0
        je L_error_division_by_zero
        cqo
        idiv rbx
        mov rdi, rax
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_remainder:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_integer(rsi)
        mov rdi, PARAM(1)
        assert_integer(rdi)
        mov rax, qword [rsi + 1]
        mov rbx, qword [rdi + 1]
        cmp rbx, 0
        je L_error_division_by_zero
        cqo
        idiv rbx
        mov rdi, rdx
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_set_car:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rax, PARAM(0)
        assert_pair(rax)
        mov rbx, PARAM(1)
        mov SOB_PAIR_CAR(rax), rbx
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_set_cdr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rax, PARAM(0)
        assert_pair(rax)
        mov rbx, PARAM(1)
        mov SOB_PAIR_CDR(rax), rbx
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_string_ref:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rdi, PARAM(0)
        assert_string(rdi)
        mov rsi, PARAM(1)
        assert_integer(rsi)
        mov rdx, qword [rdi + 1]
        mov rcx, qword [rsi + 1]
        cmp rcx, rdx
        jge L_error_integer_range
        cmp rcx, 0
        jl L_error_integer_range
        mov bl, byte [rdi + 1 + 8 + 1 * rcx]
        mov rdi, 2
        call malloc
        mov byte [rax], T_char
        mov byte [rax + 1], bl
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_vector_ref:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rdi, PARAM(0)
        assert_vector(rdi)
        mov rsi, PARAM(1)
        assert_integer(rsi)
        mov rdx, qword [rdi + 1]
        mov rcx, qword [rsi + 1]
        cmp rcx, rdx
        jge L_error_integer_range
        cmp rcx, 0
        jl L_error_integer_range
        mov rax, [rdi + 1 + 8 + 8 * rcx]
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_vector_set:
        ENTER
        cmp COUNT, 3
        jne L_error_arg_count_3
        mov rdi, PARAM(0)
        assert_vector(rdi)
        mov rsi, PARAM(1)
        assert_integer(rsi)
        mov rdx, qword [rdi + 1]
        mov rcx, qword [rsi + 1]
        cmp rcx, rdx
        jge L_error_integer_range
        cmp rcx, 0
        jl L_error_integer_range
        mov rax, PARAM(2)
        mov qword [rdi + 1 + 8 + 8 * rcx], rax
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(3)

L_code_ptr_string_set:
        ENTER
        cmp COUNT, 3
        jne L_error_arg_count_3
        mov rdi, PARAM(0)
        assert_string(rdi)
        mov rsi, PARAM(1)
        assert_integer(rsi)
        mov rdx, qword [rdi + 1]
        mov rcx, qword [rsi + 1]
        cmp rcx, rdx
        jge L_error_integer_range
        cmp rcx, 0
        jl L_error_integer_range
        mov rax, PARAM(2)
        assert_char(rax)
        mov al, byte [rax + 1]
        mov byte [rdi + 1 + 8 + 1 * rcx], al
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(3)

L_code_ptr_make_vector:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rcx, PARAM(0)
        assert_integer(rcx)
        mov rcx, qword [rcx + 1]
        cmp rcx, 0
        jl L_error_integer_range
        mov rdx, PARAM(1)
        lea rdi, [1 + 8 + 8 * rcx]
        call malloc
        mov byte [rax], T_vector
        mov qword [rax + 1], rcx
        mov r8, 0
.L0:
        cmp r8, rcx
        je .L1
        mov qword [rax + 1 + 8 + 8 * r8], rdx
        inc r8
        jmp .L0
.L1:
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_make_string:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rcx, PARAM(0)
        assert_integer(rcx)
        mov rcx, qword [rcx + 1]
        cmp rcx, 0
        jl L_error_integer_range
        mov rdx, PARAM(1)
        assert_char(rdx)
        mov dl, byte [rdx + 1]
        lea rdi, [1 + 8 + 1 * rcx]
        call malloc
        mov byte [rax], T_string
        mov qword [rax + 1], rcx
        mov r8, 0
.L0:
        cmp r8, rcx
        je .L1
        mov byte [rax + 1 + 8 + 1 * r8], dl
        inc r8
        jmp .L0
.L1:
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_numerator:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_rational(rax)
        mov rdi, qword [rax + 1]
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_denominator:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_rational(rax)
        mov rdi, qword [rax + 1 + 8]
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_eq:
	ENTER
	cmp COUNT, 2
	jne L_error_arg_count_2
	mov rdi, PARAM(0)
	mov rsi, PARAM(1)
	cmp rdi, rsi
	je .L_eq_true
	mov dl, byte [rdi]
	cmp dl, byte [rsi]
	jne .L_eq_false
	cmp dl, T_char
	je .L_char
	cmp dl, T_symbol
	je .L_symbol
	cmp dl, T_real
	je .L_real
	cmp dl, T_rational
	je .L_rational
	jmp .L_eq_false
.L_rational:
	mov rax, qword [rsi + 1]
	cmp rax, qword [rdi + 1]
	jne .L_eq_false
	mov rax, qword [rsi + 1 + 8]
	cmp rax, qword [rdi + 1 + 8]
	jne .L_eq_false
	jmp .L_eq_true
.L_real:
	mov rax, qword [rsi + 1]
	cmp rax, qword [rdi + 1]
.L_symbol:
	; never reached, because symbols are static!
	; but I'm keeping it in case, I'll ever change
	; the implementation
	mov rax, qword [rsi + 1]
	cmp rax, qword [rdi + 1]
.L_char:
	mov bl, byte [rsi + 1]
	cmp bl, byte [rdi + 1]
	jne .L_eq_false
.L_eq_true:
	mov rax, sob_boolean_true
	jmp .L_eq_exit
.L_eq_false:
	mov rax, sob_boolean_false
.L_eq_exit:
	LEAVE
	ret AND_KILL_FRAME(2)

make_real:
        ENTER
        mov rdi, (1 + 8)
        call malloc
        mov byte [rax], T_real
        movsd qword [rax + 1], xmm0
        LEAVE
        ret
        
make_integer:
        ENTER
        mov rsi, rdi
        mov rdi, (1 + 8 + 8)
        call malloc
        mov byte [rax], T_rational
        mov qword [rax + 1], rsi
        mov qword [rax + 1 + 8], 1
        LEAVE
        ret
        
L_error_integer_range:
        mov rdi, qword [stderr]
        mov rsi, fmt_integer_range
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -5
        call exit

L_error_arg_count_0:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_0
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_count_1:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_1
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_count_2:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_2
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_count_12:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_12
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_count_3:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_3
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit
        
L_error_incorrect_type:
        mov rdi, qword [stderr]
        mov rsi, fmt_type
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -4
        call exit

L_error_division_by_zero:
        mov rdi, qword [stderr]
        mov rsi, fmt_division_by_zero
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -8
        call exit

section .data
fmt_char:
        db `%c\0`
fmt_arg_count_0:
        db `!!! Expecting zero arguments. Found %d\n\0`
fmt_arg_count_1:
        db `!!! Expecting one argument. Found %d\n\0`
fmt_arg_count_12:
        db `!!! Expecting one required and one optional argument. Found %d\n\0`
fmt_arg_count_2:
        db `!!! Expecting two arguments. Found %d\n\0`
fmt_arg_count_3:
        db `!!! Expecting three arguments. Found %d\n\0`
fmt_type:
        db `!!! Function passed incorrect type\n\0`
fmt_integer_range:
        db `!!! Incorrect integer range\n\0`
fmt_division_by_zero:
        db `!!! Division by zero\n\0`
fmt_scheme_error_part_1:
        db `\n!!! The procedure \0`
fmt_scheme_error_part_2:
        db ` asked to terminate the program\n`
        db `    with the following message:\n\n\0`
fmt_scheme_error_part_3:
        db `\n\nGoodbye!\n\n\0`
