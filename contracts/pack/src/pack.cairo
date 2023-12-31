use option::OptionTrait;
use traits::{Into, TryInto};

trait Packing<T> {
    fn pack(self: T) -> felt252;
    fn overflow_pack_protection(self: T) -> T;
    fn unpack(packed: felt252) -> T;
}

//#[inline(always)]
fn rshift_split(value: u256, bits: u256) -> (u256, u256) {
    // temporary commented out until 0.12.1 when u256_safe_divmod is an allowed libfunc
    // integer::U256DivRem::div_rem(value, bits.try_into().expect('0 bits'))
    let value = integer::u512 { limb0: value.low, limb1: value.high, limb2: 0, limb3: 0 };
    let (q, r) = integer::u512_safe_div_rem_by_u256(value, bits.try_into().expect('0 bits'));
    (u256 { low: q.limb0, high: q.limb1 }, r)
}

#[cfg(test)]
mod tests {
    use super::rshift_split;
    use pack::constants::pow;

    #[test]
    #[available_gas(10000000)]
    fn test_rshift_split_pass() {
        let v = 0b11010101;

        let (q, r) = rshift_split(v, pow::TWO_POW_1);
        assert(q == 0b1101010, 'q 1 bit');
        assert(r == 0b1, 'r 1 bit');

        let (q, r) = rshift_split(v, pow::TWO_POW_2);
        assert(q == 0b110101, 'q 2 bits');
        assert(r == 0b01, 'r 2 bits');

        let (q, r) = rshift_split(v, pow::TWO_POW_3);
        assert(q == 0b11010, 'q 3 bits');
        assert(r == 0b101, 'r 3 bits');

        let (q, r) = rshift_split(v, pow::TWO_POW_4);
        assert(q == 0b1101, 'q 4 bits');
        assert(r == 0b0101, 'r 4 bits');

        let (q, r) = rshift_split(v, pow::TWO_POW_8);
        assert(q == 0, 'q 8 bits');
        assert(r == v, 'r 8 bits');
    }

    #[test]
    #[available_gas(10000000)]
    #[should_panic]
    fn test_rshift_split_0() {
        rshift_split(0b1101, 0);
    }
}
