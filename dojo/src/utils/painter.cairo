mod painter {
    use debug::PrintTrait;
    use core::byte_array::ByteArrayTrait;
    use core::array::{Array, ArrayTrait};
    use karat::models::token_data::{TokenData, TokenDataTrait};
    use karat::utils::encoding::bytes_base64_encode;

    const RES_WIDTH: usize = 600;
    const RES_HEIGHT: usize = 600;
    const WIDTH: usize = 32;
    const HEIGHT: usize = 32;
    const GAP: usize = 2;

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

    fn _svg(token_data: TokenData) -> ByteArray {
        //---------------------------
        // Build lines
        let mut lines: ByteArray = "";
        let mut l: usize = 0;
        loop {
            if (l == HEIGHT) {
                break;
            }
            let line: ByteArray = "12345678901234567890123456789012";
            lines.append(
                @format!(
                    "<text class=\"NORMAL\" x=\"0\" y=\"{}\">{}</text>",
                    l,
                    line,
                )
            );
            l += 1;
        };
        //----------------
        // Build tags
        //
        let svg_tag = format!(
            "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\" width=\"{}\" height=\"{}\" viewBox=\"-{} -{} {} {}\">",
                RES_WIDTH,
                RES_HEIGHT,
                GAP,
                GAP,
                GAP + WIDTH + GAP,
                GAP + HEIGHT + GAP,
        );
        let style_tag = format!(
            "<style>.BG{{fill:#00000b;}}.NORMAL{{letter-spacing:0.41px;}}.SCALED{{transform:scaleX(1.667);}}text{{fill:#c2e0fd;font-size:1px;font-family:'Courier New',monospace;dominant-baseline:hanging;shape-rendering:crispEdges;white-space:pre;cursor:default;-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none;}}</style>",
        );
        let bg_tag = format!(
            "<rect class=\"BG\" x=\"-{}\" y=\"-{}\" width=\"{}\" height=\"{}\" />",
                GAP,
                GAP,
                GAP + WIDTH + GAP,
                GAP + HEIGHT + GAP,
        );
        //----------------
        // Build svg
        //
        (format!(
            "{}{}<g>{}{}</g></svg>",
                svg_tag,
                style_tag,
                bg_tag,
                lines,
        ))
    }

    #[inline(always)]
    fn _encode_svg(svg: ByteArray) -> ByteArray {
        (format!("data:image/svg+xml;base64,{}", bytes_base64_encode(svg)))
    }

}


