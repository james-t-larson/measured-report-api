## Long-Term Goals

- Get reporting working (logs, and alerts)
    > a
    * [x] Get logs working
    * [ ] Get alerts working
- Add tests for all responses
    > Adding all tests takes far to much time
- Fix tests, get pre-commit hook working, even when another person pulls the project
- Image resizing needs to be added to support a responsive layout
- Switch to an open source LLM
- Add Gem for readibility
    > Can be used to guage the performance of a prompt
    * [ ] Add column to track the current prompts readibility
- Integrate with a fact checker
    > Can use the responses from this as a way to train the assistant with fine tuning.
    * [ ] Learn about different fact checkers that I can integrate with
    * [ ] Add column to prompts table to track factuality
- Integrate with some kind of plagarism checker
    > Need to make sure that these are effective.
    > Can use the responses from this as a way to train the assistant with fine tuning.
    * [ ] Add column to prompts table to track plagerism failures
- Images should mainly be sketches
    * [ ] Find image generation ai to convert images to sketches
- Integrate with a citation machine for sources
    > There is a gem called citeproc-ruby that might work. This would be good for getting all the articles around a specific event and putting them into sources for the article
- Add Morning Brief
    > This could be done with integrating with weather and traffic apis. Then write a summary on that. I could also include an estimated time to work. If there is a difference outside the norm, then it could notify me. 
- Implment some kind of bias detection
    * [ ] Add column to Prompts table to track bais failures
- Add event search
    > If no similar events are found it should write one.

## To Do

- Get client side authentication working

## Doing


## Done

- Setup docker for development and production
    * [x] Create base, and env specific docker files 
    * [x] Create base and env specific docker compose files
    * [x] Store all env vars in .env. Docker will automatticaly use this for env vars
    * [x] Try to enable starting docker with a flag -production or -development to easily start either. This is to avoid long docker-compose commands
    * [x] Ensure that the image name is tagged for production
- Get new domains with sub domains working
    * [x] Buy a domain for the Measured Gazette
    * [x] Link to static ip
    * [x] Set nginx up
- Implement Categories
    * [x] Add relevance to Articles, set the default scope to order by relevance
    * [x] Set the default scope for categories to order by position
    * [x] Finish Endpoints for creating new articles
    * [x] Ensure that the last external batch published is new before generating new articles
    * [x] Write endpoint to trigger article generation
    * [x] Ensure that duplicate articles are caught when retriving articles, there is potential that two categories catch the same article
    * [x] Add jobs for managing calls to all the different services
    * [x] Thie is the second version of the api
    * [x] Add category param to Article V2
    * [x] Implment Sports, Finance, Technology, Civics, Relavent,
    * [x] Make sure that categories and places match up, I don't care about the housing market in Montana, but I car about governance there for example
    * [x] Make needed changes to event registry service
    * [x] Use the generic response method for categories
    * [x] Update migrations to not expect null, add validations
    * [x] Rename sub_categories to external categories
    * [x] Implment Serializers, organize directories
    * [x] Write Data Preperations Service
- Get taskell working in nvim
    > https://github.com/romariorobby/taskell.nvim
    * [x] Get plugin installed
    * [x] Configure key mapping
- Update README with docker info
- Learn to send prompts to gpt from the api
- Invite Jo to the project when README is updated
- Integrate with openai, generate articles
    > Need to switch to the assitant that I created. Exmaples can be found here: https://github.com/alexrudall/ruby-openai?tab=readme-ov-file#assistants
- Move news api, api key into credentials.yml
- Change main branch to develop so that dependa bot creates PR's for it
- Change system info for generation service
- Change Story to article everywhere
- Get gpt content generated correctly
- Should generate articles from GPT and store them in the DB
    * [x] Add validations for all columns
    * [x] Make sure that sources is in the endpoint
    * [x] Add sources to the tests
    * [x] Remove published at from the tests
- Write tests for open ai generation service
- Should generate articles at noon and midnight
- Make sure that news api tests still work
- Add something so that it get politcial news in the news api integration
- Should write 5 articles
- Update README with postgres start info
- Write down some kind of roadmap.
- Write tests for the Article model
- Create Feature Spec, use github docs?
- Add date range incase there is a problem with generation development will not be stalled
    * [x] Update tests, switch defualt scope to published_today
    * [x] Should be able to get todays articles with no params on the main route.
    * [x] Should be able to get any days articles when param is passed
    * [x] When requesting a specific article should no be limited todays articles
    * [x] Should throw error if iso8601  is not used
- The default route is broken
- Throw away api dog, automate and enforce documentation
    * [x] Documentation should be auto generated, use rswag
    * [x] Use SwaggerUI to host a site that other developers can use to get docs and playwith the project
    * [x] Documentation should be  enforced in some way, use git hooks
- On start, it should check if thre are any articles for the day. If there are none, it should generate them
- Complete tests for article and model controller
    * [ ] Complete edge case tests for model
    * [ ] 
- Enforce SSL in lightsail instance
- Implment Basic authentication if toggled on. use env vars
- Integrate with the Event Registray
    * [x] Get top articles from Articles endpoint
    * [x] Pass article content into chat gpt to rewrite
    * [x] Add api key to secrets
- Complete Tests for the Article Controller
    > There are features and things that are not tested
    * [x] Should not be able to request articles for the future
    * [ ] 
- Prod should not be using seed data
- Persist database as a volume in the docker-compose file.
    > This is the reason that the database is lost when docker-compose down is run
- Link taskell and the github project
- Get a domain
- Show Articles from yesterday if no articles were generated today
    > Use the application controller to define a single wrapper for content. anything passed into this might be called data:
    * [x] define v2 artciles
    * [x] content should be wrapped in an object so messages can be sent to the client
    * [x] send error http when content is old
    * [x] needs to handle the initial creation of the project. if there are no articles at all
- Define feature spec
- Fix issue with generating articles at weird times or not at all
    * [x] Add better logs 
    * [x] Remove mid day generation. no need for that
- Add Gem for semetality
    > Can be used for tracking the performance of a prompt
- Implement Prompt Versioning
    * [x] Move Prompt into DB
    * [x] Add columns for sentiment
- Add management endpoint for prompts
    * [ ] Implment prompts spec in README
- Add tests for Prompt model
- bin/brakman should be added to my over commit hook.
    > This is to make sure that it doesn't fail security checks in the actions
- When updating a prompt it should set sentiment and usage to back to 0
- Use Git integration with SimpleCov to ensure that any change has tests written
    > simplecov-icov has a tool that can check tests for only changed files. this should ensure nearly 100% test coverage and catch anything that isn't tested
- Prompt should be changed to reduce emotional language.
    * [x] The current prompt have content that makes it easy to detect as an ai. 
    * [x] The old prompt is to complex. Reduce complexity
- Add authentication with api keys.
    * [ ] If no api key is passed reject with basic auth, do no notify the user
    * [ ] If api key is passed, but does not find a match, reject with 401 and empty body
    * [ ] There should be admin api keys
    * [ ] Should only affect v2/articles and admin routes
- BUG: Multiple articles are created with same article title, but different content
    * [x] The problem was caused by rate limiting and concurrancy issues as OpenAi takes forever, frequent retries happened
- Add admin endpoint for to trigger article generation job
- Rename everything to Measured Gazette
- Update Articles Model
- Fix categories endpoint
- Create doc for getting db and redis setup for development
- Get sentiment working properly for generated articles
    * [ ] Log difference between original article and the current prompts article
- Implement sidekiq for async workers
    > There seems to be a problem with concurrancy in the event registry. Articles are not being placed in the correct category
    * [x] configure redis store
    * [x] get docker working for development and production
    * [ ] install and set up sidekiq
    * [ ] add sidekiq as a docker container (optional)
    * [ ] Switch to sidekiq, only one job should run at a time
