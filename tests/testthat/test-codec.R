context("decode")

describe("decode", {

  datatable_colnames <- function(dt) sapply(dt$columns, function(column) column$name)
  datatable_coltypes <- function(dt) sapply(dt$columns, function(column) column$validator$items$type)

  it("decodes vectors to arrays (i.e. does nothing)", {
    expect_equal(decode(vector("numeric")), vector("numeric"))
    expect_equal(decode(1:5), 1:5)
    expect_equal(decode(TRUE), TRUE)
    expect_equal(decode(c("a", "b")), c("a", "b"))
  })

  it("decodes lists to lists (recursively)", {
    expect_equal(decode(list(a = 1, b = 2)), list(a = 1, b = 2))
  })

  describe("decodes data.frames to Datatables", {

    test_that("mtcars", {
      datatable <- decode(mtcars)

      expect_equal(length(datatable$columns), 11)
      expect_equal(
        datatable_colnames(datatable),
        c("mpg", "cyl", "disp", "hp", "drat", "wt", "qsec", "vs", "am", "gear", "carb")
      )
      expect_equal(
        datatable_coltypes(datatable),
        rep("NumberValidator", 11)
      )
    })

    test_that("chickwts", {
      datatable <- decode(chickwts)

      expect_equal(length(datatable$columns), 2)
      expect_equal(
        datatable_colnames(datatable),
        c("weight", "feed")
      )
      expect_equal(
        datatable_coltypes(datatable),
        c("NumberValidator", "EnumValidator")
      )
      expect_equal(
        datatable$columns[[2]]$validator$items$values,
        c("casein", "horsebean", "linseed", "meatmeal", "soybean", "sunflower")
      )
    })
  })

  it("decodes base plots to ImageObjects", {
    # Create a temporary device as a temp file just so we
    # don't pollute the local dir with Rplots* files
    png(tempfile())
    # Need to enable recording for print devices.
    dev.control("enable")
    plot(1, 1)
    value <- recordPlot()
    dev.off()

    image_object <- decode(value)
    expect_match(image_object$type, "ImageObject")
    expect_match(image_object$contentUrl, "^data:image")
  })

  it("decodes ggplots to ImageObjects", {
    library(ggplot2)
    value <- ggplot(mtcars, aes(x = cyl, y = mpg))

    image_object <- decode(value)
    expect_match(image_object$type, "ImageObject")
    expect_match(image_object$contentUrl, "^data:image")
  })

  it("logs a warning and returns print output for other types", {
    expect_match(decode(sum), "^function")
    expect_match(last_log()$message, "Default conversion for R type: builtin , class: function")
  })
})
