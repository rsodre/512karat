trait ShortStringTrait {
    fn strlen(self: felt252) -> usize;
    fn string(self: felt252) -> ByteArray;
}

impl ShortString of ShortStringTrait {
    fn strlen(self: felt252) -> usize {
        let mut result: usize = 0;
        let mut v: u256 = self.into();
        while (v != 0) {
            result += 1;
            v /= 0x100;
        };
        (result)
    }

    fn string(self: felt252) -> ByteArray {
        // alternative: core::to_byte_array::FormatAsByteArray
        let mut namestr: ByteArray = "";
        namestr.append_word(self, self.strlen());
        (namestr)
    }
}
