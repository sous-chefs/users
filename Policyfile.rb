# frozen_string_literal: true

name 'users'

run_list 'recipe[test::default]'

cookbook 'users', path: '.'
cookbook 'test', path: 'test/cookbooks/test'

named_run_list :default, 'recipe[test::default]'
