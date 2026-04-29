test_that("xy column picker recognizes x/y", {
  coords <- data.frame(cell = c("a", "b"), x = 1:2, y = 3:4)
  expect_equal(.pick_xy_columns(coords), c("x", "y"))
})
