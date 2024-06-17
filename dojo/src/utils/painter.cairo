mod painter {
    use debug::PrintTrait;
    use core::byte_array::ByteArrayTrait;
    use core::array::{Array, ArrayTrait};
    use karat::models::token_data::{TokenData, TokenDataTrait};

    fn build_uri(token_data: TokenData) -> ByteArray {
        let name_tag = _value_tag("name", token_data.get_name());
        let desc_tag = _value_tag("description", token_data.get_description());
        let type_tag = _value_tag("type", token_data.get_type());
        let attributes_tag = _array_tag("attributes", _attributes_array(token_data));
        (format!("{{{},{},{},{}}}",
            name_tag,
            desc_tag,
            type_tag,
            attributes_tag,
        ))
    }

    fn _attributes_array(token_data: TokenData) -> ByteArray {
        let mut result = "[";
        let mut n: u32 = 0;
        loop {
            if (n == token_data.trait_names.len() || n == token_data.trait_values.len()) {
                break;
            }
            if (n > 0) {
                result += ",";
            }
            let name: @ByteArray = token_data.trait_names.at(n);
            let value: @ByteArray = token_data.trait_values.at(n);
            result += _format_trait(name, value);
            n += 1;
        };
        result += "]";
        (result)
    }

    #[inline(always)]
    fn _value_tag(name: ByteArray, value: ByteArray) -> ByteArray {
        (format!("\"{}\":\"{}\"", name, value))
    }

    #[inline(always)]
    fn _array_tag(name: ByteArray, value: ByteArray) -> ByteArray {
        (format!("\"{}\":{}", name, value))
    }

    #[inline(always)]
    fn _format_trait(name: @ByteArray, value: @ByteArray) -> ByteArray {
        (format!("{{\"trait\":\"{}\",\"value\":\"{}\"}}", name, value))
    }

}
