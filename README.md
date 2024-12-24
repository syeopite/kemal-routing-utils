# kemal-routing-utils

Kemal Routing Utils provides helper utilities to help define and organize 
routes for an application in a more structured manner

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     kemal-routing-utils:
       github: syeopite/kemal-routing-utils
   ```

2. Run `shards install`

## Usage

```crystal
require "kemal"
require "kemal-routing-utils"

class Routes < KemalRoutingUtils::AnnotationRouter
  @[GET("/")]
  def root(env)
    "Hello world"
  end
end

Routes.new

Kemal.run
```

## Contributing

1. Fork it (<https://github.com/syeopite/kemal-routing-utils/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [syeopite](https://github.com/syeopite) - creator and maintainer
