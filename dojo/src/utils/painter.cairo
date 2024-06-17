mod painter {
    use debug::PrintTrait;
    use core::byte_array::ByteArrayTrait;
    use core::array::{Array, ArrayTrait};
    use karat::models::token_data::{TokenData, TokenDataTrait};
    use karat::utils::encoding::bytes_base64_encode;

    fn build_uri(token_data: TokenData) -> ByteArray {
        let name_tag = _value_tag("name", token_data.get_name());
        let desc_tag = _value_tag("description", token_data.get_description());
        let type_tag = _value_tag("type", token_data.get_type());
        let attributes_tag = _array_tag("attributes", _attributes_array(token_data));
        let image_tag = _value_tag("image", _encode_svg(_svg(token_data)));
        (format!("{{{},{},{},{},{}}}",
            name_tag,
            desc_tag,
            type_tag,
            attributes_tag,
            image_tag,
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

    #[inline(always)]
    fn _svg(token_data: TokenData) -> ByteArray {
        (format!(
            "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\" width=\"600\" height=\"600\" viewBox=\"-1 -1 6 6\"><style>text{{fill:#fff;font-size:1px;font-family:'Courier New',monospace;}}.BG{{fill:#000;}}</style><g><rect class=\"BG\" x=\"-1\" y=\"-1\" width=\"6\" height=\"6\" /><text x=\"0\" y=\"1\">Karat</text><text x=\"0\" y=\"2\">#{}</text></g></svg>",
             token_data.token_id,
        ))
    }

    #[inline(always)]
    fn _encode_svg(svg: ByteArray) -> ByteArray {
        (format!("data:image/svg+xml;base64,{}", bytes_base64_encode(svg)))
    }

}


