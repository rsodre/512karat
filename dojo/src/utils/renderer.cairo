mod renderer {
    use debug::PrintTrait;
    use core::byte_array::ByteArrayTrait;
    use core::array::{Array, ArrayTrait};
    use karat::models::token_data::{TokenData, TokenDataTrait, ContractData};
    use karat::models::class::{Class, ClassTrait};
    use karat::utils::encoding::bytes_base64_encode;

    const RESOLUTION: usize = 1000;
    const GAP: usize = 4;
    // // 48 x 48
    // const SIZE: usize = 48;
    // const SCALED_SIZE: usize = 29;
    // 40 x 40
    const SIZE: usize = 40;
    const SCALED_SIZE: usize = 24;
    // 36 x 36
    // const SIZE: usize = 36;
    // const SCALED_SIZE: usize = 21;
    // // 32 x 32
    // const SIZE: usize = 32;
    // const SCALED_SIZE: usize = 19;
    // // 28 x 28
    // const SIZE: usize = 28;
    // const SCALED_SIZE: usize = 17;
    // // 24 x 24
    // const SIZE: usize = 24;
    // const SCALED_SIZE: usize = 14;

    fn build_uri(token_data: TokenData) -> ByteArray {
        let name_tag = _value_tag("name", token_data.get_name());
        let desc_tag = _value_tag("description", token_data.get_description());
        let attributes_tag = _array_tag("attributes", _attributes_array(token_data));
        let image_tag = _value_tag("image", _encode_svg(_svg(token_data)));
        (_encode_uri(format!("{{{},{},{},{}}}",
            name_tag,
            desc_tag,
            attributes_tag,
            image_tag,
        )))
    }

    fn build_contract_uri(contract_data: ContractData) -> ByteArray {
        let name_tag = _value_tag("name", contract_data.name);
        let symbol_tag = _value_tag("symbol", contract_data.symbol);
        let desc_tag = _value_tag("description", contract_data.description);
        let link_tag = _value_tag("external_link", contract_data.external_link);
        let image_tag = _value_tag("image", contract_data.image);
        (_encode_uri(format!("{{{},{},{},{},{}}}",
            name_tag,
            symbol_tag,
            desc_tag,
            link_tag,
            image_tag,
        )))
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
    fn _encode_svg(data: ByteArray) -> ByteArray {
        (format!("data:image/svg+xml;base64,{}", bytes_base64_encode(data)))
        // (format!("data:image/svg+xml,{}", data)) // not encoded
    }

    #[inline(always)]
    fn _encode_uri(data: ByteArray) -> ByteArray {
        // (format!("data:application/json;base64,{}", bytes_base64_encode(data)))
        (format!("data:application/json,{}", data)) // not encoded
    }


    //------------------------
    // SVG builder
    //
    fn _svg(token_data: TokenData) -> ByteArray {
        let mut result: ByteArray = "";
        let _WIDTH: usize = (GAP + SIZE + GAP);
        result.append(@format!(
            "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\" width=\"{}\" height=\"{}\" viewBox=\"-{} -{} {} {}\">",
                RESOLUTION,
                RESOLUTION,
                GAP,
                GAP,
                _WIDTH,
                _WIDTH,
        ));
        result.append(@"<style>.BG{fill:#00000b;}.NORMAL{letter-spacing:0;}.SCALED{transform:scaleX(1.667);}text{fill:#c2e0fd;font-size:1px;font-family:'Courier New',monospace;dominant-baseline:hanging;shape-rendering:crispEdges;white-space:pre;cursor:default;-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none;}</style>");
        let class_name: ByteArray = if (token_data.class.is_scaled()) {"SCALED"} else {"NORMAL"};
        result.append(@format!(
            "<g><rect class=\"BG\" x=\"-{}\" y=\"-{}\" width=\"{}\" height=\"{}\" /><g class=\"{}\">",
                GAP,
                GAP,
                _WIDTH,
                _WIDTH,
                class_name,
        ));
        //---------------------------
        // Build text tags
        //
        let text_length: usize = if (token_data.class.is_scaled()) {SCALED_SIZE} else {SIZE};
        let char_set: Span<felt252> = token_data.class.get_char_set();
        let char_set_sizes: Span<usize> = token_data.class.get_char_set_sizes();
        let char_count: usize = char_set.len();
        let cells: Span<usize> = _make_cells(token_data.seed, char_count);
        let mut y: usize = 0;
        loop {
            if (y == SIZE) { break; }
            // open <text>
            result.append(@format!(
                "<text y=\"{}\" textLength=\"{}\">",
                    y,
                    text_length,
            ));
            let mut x: usize = 0;
            loop {
                if (x == SIZE) { break; }
                let value: @usize = cells.at(y * SIZE + x);
                result.append_word(*char_set.at(*value), *char_set_sizes.at(*value));
                x += 1;
            };
            // close <text>
            result.append(@"</text>");
            y += 1;
        };
        //----------------
        // close it!
        //
        result.append(@"</g></g></svg>");
        (result)
    }


    //------------------------
    // token cell builder
    //
    fn _make_cells(seed: u128, char_count: usize) -> Span<usize> {
        // seed params
        let HALF_SIZE: usize = (SIZE / 2);
        let off_x: usize = ((seed / 0x100) % HALF_SIZE.into()).try_into().unwrap();
        let off_y: usize = ((seed / 0x10000) % HALF_SIZE.into()).try_into().unwrap();
        let sc_x: usize = ((seed / 0x1000000) % HALF_SIZE.into()).try_into().unwrap();
        let sc_y = sc_x * ((seed / 0x100000000) % 3).try_into().unwrap();
        let mod_x: usize = 1 + ((seed / 0x10000000000) % char_count.into()).try_into().unwrap();
        let mod_y: usize = 1 + ((seed / 0x1000000000000) % char_count.into()).try_into().unwrap();
        let fade_type: usize = ((seed / 0x100000000000000) % 10).try_into().unwrap();
        let fade_amount: usize = 1 + ((seed / 0x10000000000000000) % 3).try_into().unwrap();
        // build cells
        let mut cells:Array<usize> = array![];
        let mut y: usize = 0;
        loop {
            if (y == SIZE) { break; }
            let mut x: usize = 0;
            loop {
                if (x == SIZE) { break; }
                let mut value: usize = 0;

                if (x < HALF_SIZE && y < HALF_SIZE) {
                    // generate Q1
                    value = (
                        (x * sc_x) + off_x + (x % mod_x) +
                        (y * sc_y) + off_y + (y % mod_y)
                    ) % char_count;
                    // fade out borders
                    let mut f: usize = 0;
                    if ((x + y) < HALF_SIZE) {
                        if (fade_type >= 1 && fade_type <= 3) { // inverted border
                            f = (x + y) / fade_amount;
                        } else { // normal
                            f = ((HALF_SIZE-x) + (HALF_SIZE-y) - HALF_SIZE) / fade_amount;
                        }
                    } else if (fade_type == 0) { // inside-out
                        f = (x + y - HALF_SIZE) / fade_amount;
                    }
                    if (f > 0) {
                        value -= if (f > value) {value} else {f};
                    }
                } else if (y < HALF_SIZE) {
                    // mirror Q2
                    value = *cells.at(y*SIZE + (SIZE-x-1));
                } else {
                    // mirror Q3/Q4121
                    value = *cells.at((SIZE-y-1)*SIZE + x);
                }
                cells.append(value);
                x += 1;
            };
            y += 1;
        };
        (cells.span())
    }

}


