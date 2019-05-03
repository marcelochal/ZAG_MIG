FUNCTION-POOL ZKCDE.                    "MESSAGE-ID ..
type-pools: kcde,
            kcdu,
            kpp  .

set extended check off.
include ole2incl.
include lkcded00.
tables: kcdekey,
        kcdehead,
        kcdefile,
        kcdedatar.
set extended check on.

data: break_level value '2'.


types: begin of type_group_datar_struc,
         group_id like kcdedatar-range_id,
         range_id like kcdedatar-range_id,
       end of type_group_datar_struc,
       type_group_datar type type_group_datar_struc occurs 10.

*data: break_name like sy-uname.
define break_sub.
*  break_name = ' '.
  case break_level.
*    when '2'. if sy-uname = break_name.  endif.
    when '1'. message s001(kx) with '.'.
  endcase.
end-of-definition.

constants: c_comma  value ',',
           c_point  value '.',
           c_esc    value '"'.
*           C_ESC_END(2) VALUE '",'.
data: g_appl like c_kcd.
