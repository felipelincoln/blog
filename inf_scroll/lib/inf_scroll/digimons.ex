defmodule InfScroll.Digimons do

  def list_digimons(page, per_page \\ 10) do
    list_digimons()
    |> Enum.chunk_every(per_page)
    |> List.pop_at(page)
    |> (fn {item, _new_list} -> item || [] end).()
  end

  def list_digimons do
    [
      %{
        category: :baby,
        name: "botamon"
      },
      %{
        category: :baby,
        name: "punimon"
      },
      %{
        category: :baby,
        name: "poyomon"
      },
      %{
        category: :baby,
        name: "yuramon"
      },
      %{
        category: :trainee,
        name: "koromon"
      },
      %{
        category: :trainee,
        name: "tsunomon"
      },
      %{
        category: :trainee,
        name: "tokomon"
      },
      %{
        category: :trainee,
        name: "tanemon"
      },
      %{
        category: :rookie,
        name: "agumon"
      },
      %{
        category: :rookie,
        name: "betamon"
      },
      %{
        category: :rookie,
        name: "elecmon"
      },
      %{
        category: :rookie,
        name: "gabumon"
      },
      %{
        category: :rookie,
        name: "kunemon"
      },
      %{
        category: :rookie,
        name: "palmon"
      },
      %{
        category: :rookie,
        name: "patamon"
      },
      %{
        category: :rookie,
        name: "penguinmon"
      },
      %{
        category: :rookie,
        name: "piyomon"
      },
      %{
        category: :champion,
        name: "airdramon"
      },
      %{
        category: :champion,
        name: "angemon"
      },
      %{
        category: :champion,
        name: "bakemon"
      },
      %{
        category: :champion,
        name: "birdramon"
      },
      %{
        category: :champion,
        name: "centaurumon"
      },
      %{
        category: :champion,
        name: "coelamon"
      },
      %{
        category: :champion,
        name: "devimon"
      },
      %{
        category: :champion,
        name: "drimogemon"
      },
      %{
        category: :champion,
        name: "frigimon"
      },
      %{
        category: :champion,
        name: "garurumon"
      },
      %{
        category: :champion,
        name: "greymon"
      },
      %{
        category: :champion,
        name: "kabuterimon"
      },
      %{
        category: :champion,
        name: "kokatorimon"
      },
      %{
        category: :champion,
        name: "kuwagamon"
      },
      %{
        category: :champion,
        name: "leomon"
      },
      %{
        category: :champion,
        name: "meramon"
      },
      %{
        category: :champion,
        name: "monochromon"
      },
      %{
        category: :champion,
        name: "mojyamon"
      },
      %{
        category: :champion,
        name: "nanimon"
      },
      %{
        category: :champion,
        name: "ninjamon"
      },
      %{
        category: :champion,
        name: "nunemon"
      },
      %{
        category: :champion,
        name: "ogremon"
      },
      %{
        category: :champion,
        name: "seadramon"
      },
      %{
        category: :champion,
        name: "shellmon"
      },
      %{
        category: :champion,
        name: "sukamon"
      },
      %{
        category: :champion,
        name: "tyranomon"
      },
      %{
        category: :champion,
        name: "unimon"
      },
      %{
        category: :champion,
        name: "veggiemon"
      },
      %{
        category: :champion,
        name: "whamon"
      },
      %{
        category: :ultimate,
        name: "andromon"
      },
      %{
        category: :ultimate,
        name: "digitamamon"
      },
      %{
        category: :ultimate,
        name: "etemon"
      },
      %{
        category: :ultimate,
        name: "giromon"
      },
      %{
        category: :ultimate,
        name: "herculeskabuterimon"
      },
      %{
        category: :ultimate,
        name: "mamemon"
      },
      %{
        category: :ultimate,
        name: "megadramon"
      },
      %{
        category: :ultimate,
        name: "megaseadramon"
      },
      %{
        category: :ultimate,
        name: "metalgreymon"
      },
      %{
        category: :ultimate,
        name: "metalmamemon"
      },
      %{
        category: :ultimate,
        name: "monzaemon"
      },
      %{
        category: :ultimate,
        name: "phonixmon"
      },
      %{
        category: :ultimate,
        name: "piximon"
      },
      %{
        category: :ultimate,
        name: "skullgreymon"
      },
      %{
        category: :ultimate,
        name: "vademon"
      }
    ]
  end
end
