# Records that describe a batch kernel. A family file registers its kernels
# by adding `_batch_kernel` methods that return one of these.

struct _BatchKernel{P,F}
    eligible::P
    evaluate::F
end

struct _BatchRepair{K}
    kernel::K
    placeholder::Double64
end

struct _BatchAlternatives{P,S}
    preferred::P
    secondary::S
end

_batch_kernel(f, result, types...) = nothing
const _BATCH_BLOCK = 64
# Shorter blocks retain more eligible lanes when a mixed block needs
# scalar evaluation. Repair uses the full width of its UInt64 mask.
_batch_width(k) = 32
_batch_width(k::_BatchRepair) = _BATCH_BLOCK
_batch_width(k::_BatchAlternatives) = _batch_width(k.preferred)
