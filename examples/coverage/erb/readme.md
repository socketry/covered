# ERB Example

This example shows the coverage computation on ERB templates:

## Usage

Simply run the `coverage.rb` script:

```
> ./coverage.rb 

template.erb
   Line|   Hits|
      1|     16|<% for @item in @items %>
      2|     12|	<%= @item %>
      3|      4|<% end %>
      4|       |
      5|      4|<% if 1 == 2 %>
      6|       |	Math is broken.
      7|      4|<% end %>
** 6/6 lines executed; 100.0% covered.

* 1 files checked; 6/6 lines executed; 100.0% covered.
```

You will see the coverage for the `template.erb` file.
