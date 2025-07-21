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
  Cat(id: String, url: String)
}

fn init(_args) -> #(Model, Effect(Msg)) {
  let model = Model(total: 0, cats: [])

  #(model, effect.none())
}

fn get_cat() -> Effect(Msg) {
  let decoder = {
    use id <- decode.field("id", decode.string)
    use url <- decode.field("url", decode.string)

    decode.success(Cat(id:, url:))
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
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UserClickedAddCat -> #(model, get_cat())

    UserClickedRemoveCat -> #(
      Model(
        total: model.total - 1,
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
    html.div([], [
      html.button([event.on_click(UserClickedAddCat)], [html.text("Add cat")]),
      html.p([], [html.text(int.to_string(model.total))]),
      html.button([event.on_click(UserClickedRemoveCat)], [
        html.text("Remove cat"),
      ]),
      html.p([], []),
      html.button([event.on_click(UserClickedReset)], [html.text("Reset")]),
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
