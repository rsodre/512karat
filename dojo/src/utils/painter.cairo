mod painter {
    use debug::PrintTrait;
    use karat::models::token_data::{TokenData, TokenDataTrait};

    fn build_uri(token_data: TokenData) -> ByteArray {
        let name_tag = _format_tag("name", token_data.get_name());
        let desc_tag = _format_tag("description", token_data.get_description());
        (format!("{{{},{}}}",
            name_tag,
            desc_tag,
        ))
    }

    #[inline(always)]
    fn _format_tag(name: ByteArray, value: ByteArray) -> ByteArray {
        (format!("\"{}\":\"{}\"", name, value))
    }

}
