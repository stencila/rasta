context("json")

describe("to_node", {
  it("transforms lists into nodes of the correct type", {
    # These are NOT transformed
    expect_equal(to_node(NULL), NULL)
    expect_equal(to_node(TRUE), TRUE)
    expect_equal(to_node(1), 1)
    expect_equal(to_node("str"), "str")
    expect_equal(to_node(1:10), 1:10)
    expect_equal(to_node(list()), list())
    expect_equal(to_node(list(type = "Foo")), list(type = "Foo"))

    # These are transformed
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

describe("round trippin", {
  it("works with CodeChunks", {
    json <- '{
  "type": "CodeChunk",
  "id": "fig1",
  "text": "plot(1)",
  "programmingLanguage": "r",
  "caption": [
    {
      "type": "Heading",
      "content": ["Figure title"],
      "depth": 2
    },
    {
      "type": "Paragraph",
      "content": [
        "A paragraph with some",
        {
          "type": "Strong",
          "content": ["strong ", "emphasis"]
        },
        "in it."
      ]
    }
  ],
  "label": "Figure 1"
}'
    node <- stencilaschema::CodeChunk(
      programmingLanguage = "r",
      text = "plot(1)",
      label = "Figure 1",
      id = "fig1",
      caption = list(
        stencilaschema::Heading(
          content = "Figure title",
          depth = as.integer(2)
        ),
        stencilaschema::Paragraph(
          content = list(
            "A paragraph with some",
            stencilaschema::Strong(content = c("strong ", "emphasis")),
            "in it."
          )
        )
      )
    )

    expect_equal(from_json(json), node)
    expect_equal(to_json(node, pretty = TRUE), json)

    expect_equal(to_json(from_json(json), pretty = TRUE), json)
    expect_equal(from_json(to_json(node)), node)
  })
})