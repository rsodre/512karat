mod painter {
    use debug::PrintTrait;
    use core::byte_array::ByteArrayTrait;
    use core::array::{Array, ArrayTrait};
    use karat::models::token_data::{TokenData, TokenDataTrait};
    use karat::models::class::{Class, ClassTrait};
    use karat::utils::encoding::bytes_base64_encode;

    const RES_WIDTH: usize = 1000;
    const RES_HEIGHT: usize = 1000;
    const WIDTH: usize = 48;
    const HEIGHT: usize = 48;
    const GAP: usize = 4;

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
        let class_name: ByteArray = if (token_data.class.is_scaled()) {"SCALED"} else {"NORMAL"};
        let char_set: Span<ByteArray> = token_data.class.get_char_set();
        let char_count: usize = char_set.len();
        let mut lines: ByteArray = "";
        let mut y: usize = 0;
        loop {
            if (y == HEIGHT) { break; }
            let mut line: ByteArray = "";
            let mut x: usize = 0;
            loop {
                if (x == WIDTH) { break; }
                line.append(char_set.at((x+y) % char_count));
                x += 1;
            };
            lines.append(@format!(
                "<text class=\"{}\" x=\"0\" y=\"{}\">{}</text>",
                    class_name,
                    y,
                    line,
            ));
            y += 1;
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
            "<style>.BG{{fill:#00000b;}}.NORMAL{{letter-spacing:0;}}.SCALED{{transform:scaleX(1.667);}}text{{fill:#c2e0fd;font-size:1px;font-family:'Courier New',monospace;dominant-baseline:hanging;shape-rendering:crispEdges;white-space:pre;cursor:default;-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none;}}</style>",
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


