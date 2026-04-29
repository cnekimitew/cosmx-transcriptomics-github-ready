test_that("sample IDs are normalized", {
  expect_equal(normalize_sample_id("R6101_1657DLAD"), "R6101.1657DLAD")
})
