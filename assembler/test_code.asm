LDUR X0,  [XZR, #0]      -- Loads X0 = 0x0000000000000008
LDUR X1,  [XZR, #8]      -- Loads X1 = 0x0000000000000005
LDUR X12, [XZR, #16]     -- Loads X12 = 0xFEDCBA9876543210
LDUR X13, [XZR, #24]     -- Loads X13 = 0x0123456789ABCDEF
ADD X4,  X0, X1          -- X4 = X0 + X1 = 0x000000000000000D (13)
SUB X25, X0, X1          -- X25 = X0 - X1 = 0x0000000000000003 (3)
SUB X16, X1, X0          -- X16 = X1 - X0 = 0xFFFFFFFFFFFFFFFD (-3)
ORR X30, X12, X13        -- X30 = X12 OR X13 = 0xFFFFFFFFFFFFFFFF (all bits set)
AND X8,  X12, X13        -- X8  = X12 AND X13 = 0x0000000000000000 (all bits cleared)
ORR XZR, X0, X1          -- Attempts to write XZR = X0 OR X1 (0xE),
                         -- but XZR is hardwired to zero and cannot be modified
CBZ XZR, #3              -- Since XZR is still zero, branch forward by 3 instructions
STUR XZR, [X9, #32]      -- Would incorrectly store XZR if it had been overwritten
                         -- (not executed due to the branch)
B #0                     -- Infinite loop (not executed)
STUR X4,  [XZR, #32]     -- Stores X4 at memory addresses [32–39]
STUR X25, [XZR, #40]     -- Stores X25 at memory addresses [40–47]
STUR X16, [XZR, #48]     -- Stores X16 at memory addresses [48–55]
STUR X30, [XZR, #56]     -- Stores X30 at memory addresses [56–63]
STUR X8,  [XZR, #64]     -- Stores X8  at memory addresses [64–71]
B #0                     -- Infinite loop
