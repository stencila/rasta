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

    test_that("column types are converted to validators correctly", {
      dt <- decode(
        data.frame(
          a = 1:2,
          b = c(TRUE, FALSE),
          c = c("x", "y"),
          d = factor(c("X", "Y"), levels = c("X", "Y", "Z")),
          stringsAsFactors = FALSE
        )
      )

      expect_equal(length(dt$columns), 4)
      expect_equal(
        datatable_colnames(dt),
        c("a", "b", "c", "d")
      )
      expect_equal(
        datatable_coltypes(dt),
        c("NumberValidator", "BooleanValidator", "StringValidator", "EnumValidator")
      )
      expect_equal(
        dt$columns[[4]]$validator$items$values,
        c("X", "Y", "Z")
      )
    })

    test_that("does not decode some column types", {
      dt <- decode(
        data.frame(
          nums = 1:3,
          funcs = I(list(min, max, sum)),
          lists = I(list(list(), list(), list())),
          factor = c("huey", "dewey", "louie")
        )
      )

      expect_equal(length(dt$columns), 2)
      expect_equal(
        datatable_colnames(dt),
        c("nums", "factor")
      )
      expect_equal(
        datatable_coltypes(dt),
        c("NumberValidator", "EnumValidator")
      )
    })

    test_that("decodes mtcars", {
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

    test_that("decodes chickwts", {
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

    test_that("decodes single row data.frame to JSON correctly", {
      # This is a regression test added when it was found that
      # a single row data.frame, when converted to JSON had a scalar,
      # instead of an array, for it's column values
      datatable <- decode(data.frame(a = 1, b = as.factor("a")))

      expect_equal(length(datatable$columns), 2)
      expect_equal(
        datatable_colnames(datatable),
        c("a", "b")
      )
      expect_equal(
        datatable_coltypes(datatable),
        c("NumberValidator", "EnumValidator")
      )

      expect_equal(datatable$columns[[1]]$values, 1)
      expect_equal(datatable$columns[[2]]$values, "a")

      expect_equal(
        to_json(datatable),
        # nolint start
        '{"type":"Datatable","columns":[{"type":"DatatableColumn","name":"a","values":[1],"validator":{"type":"ArrayValidator","itemsValidator":{"type":"NumberValidator"}}},{"type":"DatatableColumn","name":"b","values":["a"],"validator":{"type":"ArrayValidator","itemsValidator":{"type":"EnumValidator","values":["a"]}}}]}'
        # nolint end
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
