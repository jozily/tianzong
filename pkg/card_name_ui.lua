local M = {}

local interactionPath = "packages/tianzong/qml/TianzongCardNameInteraction.qml"

function M.create(spec)
  spec = type(spec) == "table" and spec or {}
  local choices = type(spec.choices) == "table" and spec.choices or {}
  if #choices == 0 then return end

  local default = spec.default or choices[1]
  return {
    type = "custom",
    default = default,
    qml = {
      url = interactionPath,
      prop = {
        choices = choices,
        allChoices = spec.all_choices or choices,
        defaultChoice = default,
      },
    },
  }
end

return M
