import gleam/dynamic/decode
import gleam/int
import gleam/list
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import rsvp

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model {
  Model(total: Int, cats: List(Cat))
}

type Cat {
  Cat(id: String, url: String, width: Int, height: Int)
}

fn init(_args) -> #(Model, Effect(Msg)) {
  let model = Model(total: 0, cats: [])

  #(model, effect.none())
}

fn get_cat() -> Effect(Msg) {
  let decoder = {
    use id <- decode.field("id", decode.string)
    use url <- decode.field("url", decode.string)
    use width <- decode.field("width", decode.int)
    use height <- decode.field("height", decode.int)

    decode.success(Cat(id:, url:, width:, height:))
  }
  let url = "https://api.thecatapi.com/v1/images/search"
  let handler = rsvp.expect_json(decode.list(decoder), ApiReturnedCats)

  rsvp.get(url, handler)
}

type Msg {
  UserClickedAddCat
  UserClickedRemoveCat
  UserClickedReset
  ApiReturnedCats(Result(List(Cat), rsvp.Error))
  UpdateName(String)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UpdateName(_s) -> #(model, effect.none())
    UserClickedAddCat -> #(model, get_cat())

    UserClickedRemoveCat -> #(
      Model(
        total: int.max(model.total - 1, 0),
        cats: list.reverse(list.drop(list.reverse(model.cats), 1)),
      ),
      effect.none(),
    )

    UserClickedReset -> init(1)

    ApiReturnedCats(Ok(cats)) -> #(
      Model(model.total + 1, cats: list.append(model.cats, cats)),
      effect.none(),
    )

    ApiReturnedCats(Error(_)) -> #(model, effect.none())
  }
}

fn view(model: Model) -> Element(Msg) {
  html.div([], [
    html.div([attribute.class("form-select rounded-full px-4 py-3")], [
      html.input([attribute.value("TEST"), event.on_input(UpdateName)]),
      html.input([
        attribute.value("SOmething Else!!!!"),
        attribute.type_("checkbox"),
        attribute.class("rounded text-pink-500"),
      ]),
    ]),
    html.div([attribute.class("p-4 rounded shadow max-w-md")], [
      html.button(
        [
          attribute.class("bg-green-500 text-white p-2"),
          event.on_click(UserClickedAddCat),
        ],
        [html.text("Add cat")],
      ),
      html.p([], [html.text(int.to_string(model.total))]),
      html.button(
        [
          attribute.class("bg-red-500 text-white p-2"),
          event.on_click(UserClickedRemoveCat),
        ],
        [html.text("Remove cat")],
      ),
      html.p([], []),
      html.button(
        [
          attribute.class("bg-gray-500 text-white p-2"),
          event.on_click(UserClickedReset),
        ],
        [html.text("Reset")],
      ),
    ]),
    html.div([], {
      list.map(model.cats, fn(cat) {
        html.img([
          attribute.src(cat.url),
          attribute.width(400),
          attribute.height(400),
        ])
      })
    }),
  ])
}
