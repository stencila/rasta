context("json")

describe("to_node", {
  it("transforms lists into nodes of the correct type", {
    # These are not transformed
    expect_equal(to_node(NULL), NULL)
    expect_equal(to_node(TRUE), TRUE)
    expect_equal(to_node(1), 1)
    expect_equal(to_node("str"), "str")
    expect_equal(to_node(1:10), 1:10)
    expect_equal(to_node(list()), list())
    expect_equal(to_node(list(type = "Foo")), list(type = "Foo"))

    # These are...
    expect_equal(
      to_node(list(type = "CodeChunk", text = "some code")),
      CodeChunk(text = "some code")
    )
    expect_equal(
      to_node(list(
        type = "CodeChunk",
        text = "plot(1)",
        outputs = list(list(type = "ImageObject", contentUrl = "data:image..."))
      )),
      CodeChunk(
        text = "plot(1)",
        outputs = list(ImageObject(contentUrl = "data:image..."))
      )
    )
  })
})
