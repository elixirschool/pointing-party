use Mix.Config

config :pointing_party,
  cards: [
    %{
      title: "Support loading data from a database",
      description: """
      We need to update the application to read users and cards from the database. This work includes adding Repo to the
      project, creating migrations, and a seed.exs file.
      """
    },
    %{
      title: "Save pointing results to database",
      description: """
      Update the application to save an individual's vote and the final card points to the database.
      """
    },
    %{
      title: "Add Guardian dependency",
      description: """
      In preparation for adding authentication to the application, we need to add the Guardian dependency.
      """
    },
    %{
      title: "Create Auth module and config",
      description: """
      Create a module that uses the Guardian package and implements the approach set of callbacks. Additionally,
      add the Guardian configuration.
      """
    },
    %{
      title: "Update authenication flow to use new auth",
      description: """
      Update our existing authentication flow to use the newly created Auth module.
      """
    }
  ]
