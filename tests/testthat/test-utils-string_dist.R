context("test-utils-string_dist")

test_that("string_dist works", {
  expect_equal(as.numeric(string_dist("abc", "abc")), 1)
  expect_equal(as.numeric(string_dist("abCc", "abcc")), 0.75)
})
