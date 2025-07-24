import Testing

// MARK: - Component Type Tags
extension Tag {
    @Tag static var filter: Self
    @Tag static var `operator`: Self
}

// MARK: - Filter Tags
extension Tag {
    @Tag static var absFilter: Self
    @Tag static var appendFilter: Self
    @Tag static var atLeastFilter: Self
    @Tag static var atMostFilter: Self
    @Tag static var base64DecodeFilter: Self
    @Tag static var base64EncodeFilter: Self
    @Tag static var base64UrlSafeDecodeFilter: Self
    @Tag static var base64UrlSafeEncodeFilter: Self
    @Tag static var capitalizeFilter: Self
    @Tag static var ceilFilter: Self
    @Tag static var compactFilter: Self
    @Tag static var concatFilter: Self
    @Tag static var dateFilter: Self
    @Tag static var defaultFilter: Self
    @Tag static var dividedByFilter: Self
    @Tag static var downcaseFilter: Self
    @Tag static var escapeFilter: Self
    @Tag static var escapeOnceFilter: Self
    @Tag static var firstFilter: Self
    @Tag static var findFilter: Self
    @Tag static var findIndexFilter: Self
    @Tag static var floorFilter: Self
    @Tag static var hmacSha1Filter: Self
    @Tag static var hmacSha256Filter: Self
    @Tag static var joinFilter: Self
    @Tag static var lastFilter: Self
    @Tag static var lstripFilter: Self
    @Tag static var mapFilter: Self
    @Tag static var md5Filter: Self
    @Tag static var minusFilter: Self
    @Tag static var moduloFilter: Self
    @Tag static var newlineToBrFilter: Self
    @Tag static var plusFilter: Self
    @Tag static var prependFilter: Self
    @Tag static var rejectFilter: Self
    @Tag static var removeFilter: Self
    @Tag static var removeFirstFilter: Self
    @Tag static var removeLastFilter: Self
    @Tag static var replaceFilter: Self
    @Tag static var replaceFirstFilter: Self
    @Tag static var replaceLastFilter: Self
    @Tag static var reverseFilter: Self
    @Tag static var roundFilter: Self
    @Tag static var rstripFilter: Self
    @Tag static var sha1Filter: Self
    @Tag static var sha256Filter: Self
    @Tag static var sizeFilter: Self
    @Tag static var sliceFilter: Self
    @Tag static var sortFilter: Self
    @Tag static var sortNaturalFilter: Self
    @Tag static var splitFilter: Self
    @Tag static var stripFilter: Self
    @Tag static var stripHtmlFilter: Self
    @Tag static var stripNewlinesFilter: Self
    @Tag static var timesFilter: Self
    @Tag static var truncateFilter: Self
    @Tag static var truncatewordsFilter: Self
    @Tag static var unescapeFilter: Self
    @Tag static var uniqFilter: Self
    @Tag static var upcaseFilter: Self
    @Tag static var urlDecodeFilter: Self
    @Tag static var urlEncodeFilter: Self
    @Tag static var whereFilter: Self
}

// MARK: - Operator Tags
extension Tag {
    @Tag static var equalsOperator: Self
    @Tag static var notEqualsOperator: Self
    @Tag static var greaterThanOperator: Self
    @Tag static var greaterThanOrEqualOperator: Self
    @Tag static var lessThanOperator: Self
    @Tag static var lessThanOrEqualOperator: Self
    @Tag static var containsOperator: Self
    @Tag static var andOperator: Self
    @Tag static var orOperator: Self
}